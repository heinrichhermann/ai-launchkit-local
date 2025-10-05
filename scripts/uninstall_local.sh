#!/bin/bash

set -e

# AI LaunchKit Local - Uninstall Script
# This script safely removes AI LaunchKit while preserving Portainer

# Source the utilities file
source "$(dirname "$0")/utils.sh"

# Get script and project directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    log_error "Please run as root (use sudo)"
    exit 1
fi

# Welcome message
echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║            ⚠️  AI LAUNCHKIT - UNINSTALL UTILITY                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Check if AI LaunchKit is installed
if ! docker ps -a | grep -q "localai"; then
    log_warning "AI LaunchKit (localai project) not found in Docker"
    log_info "Nothing to uninstall"
    exit 0
fi

# Display current status
log_info "📊 Current AI LaunchKit Status"
echo "=========================================="
echo "Running containers:"
docker ps --filter "label=com.docker.compose.project=localai" --format "  - {{.Names}} ({{.Status}})"
echo ""
echo "Stopped containers:"
docker ps -a --filter "label=com.docker.compose.project=localai" --filter "status=exited" --format "  - {{.Names}}"
echo ""
echo "Volumes:"
docker volume ls --filter "name=localai_" --format "  - {{.Name}}"
echo ""

# Warning message
log_warning "⚠️  IMPORTANT: This will remove AI LaunchKit"
echo ""
echo "What will be REMOVED:"
echo "  ❌ All AI LaunchKit containers (n8n, Flowise, Ollama, etc.)"
echo "  ❌ All AI LaunchKit data volumes (workflows, databases, files)"
echo "  ❌ AI LaunchKit Docker networks"
echo "  ❌ Unused AI LaunchKit images"
echo ""
echo "What will be PRESERVED:"
echo "  ✅ Portainer (Docker Management UI on port 9443)"
echo "  ✅ Other Docker containers not part of AI LaunchKit"
echo "  ✅ Your .env configuration file (optionally backed up)"
echo "  ✅ Project directory and scripts"
echo ""

# Confirmation required
log_error "⚠️  THIS ACTION CANNOT BE UNDONE!"
echo ""
read -p "Type 'yes' to confirm uninstall (anything else cancels): " confirm

if [ "$confirm" != "yes" ]; then
    log_info "Uninstall cancelled by user"
    exit 0
fi

# Backup option
echo ""
log_info "🗄️  Backup Options"
echo "=========================================="
echo ""
read -p "Create backup before removal? (Y/n): " backup_choice

if [[ ! "$backup_choice" =~ ^[Nn]$ ]]; then
    BACKUP_DIR="$HOME/ai-launchkit-backup-$(date +%Y%m%d-%H%M%S)"
    
    log_info "Creating backup in: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    
    # Backup .env file
    if [ -f "$ENV_FILE" ]; then
        log_info "Backing up .env configuration..."
        cp "$ENV_FILE" "$BACKUP_DIR/.env.backup"
    fi
    
    # Backup n8n workflows if n8n is running
    if docker ps | grep -q "n8n"; then
        log_info "Backing up n8n workflows..."
        docker exec n8n n8n export:workflow --backup --output=/data/backup/workflows-$(date +%Y%m%d).json 2>/dev/null || true
    fi
    
    # Backup PostgreSQL databases
    if docker ps | grep -q "postgres"; then
        log_info "Backing up PostgreSQL databases..."
        docker exec postgres pg_dumpall -U postgres > "$BACKUP_DIR/postgres-backup-$(date +%Y%m%d).sql" 2>/dev/null || true
    fi
    
    # Backup critical volumes
    log_info "Backing up Docker volumes (this may take a few minutes)..."
    for volume in $(docker volume ls -q | grep "^localai_"); do
        volume_name=$(basename "$volume")
        log_info "  - Backing up $volume_name..."
        docker run --rm \
            -v "$volume":/source:ro \
            -v "$BACKUP_DIR":/backup \
            alpine \
            tar czf "/backup/${volume_name}.tar.gz" -C /source . 2>/dev/null || true
    done
    
    log_success "✅ Backup completed: $BACKUP_DIR"
    echo ""
    sleep 2
fi

# Check Portainer status
log_info "🔍 Checking Portainer Status"
echo "=========================================="
PORTAINER_INSTALLED=false
PORTAINER_RUNNING=false

if docker ps -a | grep -q "portainer"; then
    PORTAINER_INSTALLED=true
    if docker ps | grep -q "portainer"; then
        PORTAINER_RUNNING=true
        log_success "✅ Portainer is installed and running (port 9443)"
    else
        log_info "⚠️  Portainer is installed but not running"
    fi
else
    log_warning "❌ Portainer not found"
fi
echo ""

# Stop AI LaunchKit services
log_info "🛑 Stopping AI LaunchKit Services"
echo "=========================================="
cd "$PROJECT_ROOT"

log_info "Stopping all services (this may take a minute)..."
docker compose -p localai -f docker-compose.local.yml down 2>/dev/null || {
    log_warning "Could not stop services gracefully, forcing stop..."
    docker ps --filter "label=com.docker.compose.project=localai" -q | xargs -r docker stop
}

log_success "✅ All services stopped"
echo ""

# Remove containers
log_info "🗑️  Removing AI LaunchKit Containers"
echo "=========================================="
CONTAINER_COUNT=$(docker ps -a --filter "label=com.docker.compose.project=localai" -q | wc -l)

if [ "$CONTAINER_COUNT" -gt 0 ]; then
    log_info "Removing $CONTAINER_COUNT containers..."
    docker ps -a --filter "label=com.docker.compose.project=localai" -q | xargs -r docker rm -f
    log_success "✅ Containers removed"
else
    log_info "No containers to remove"
fi
echo ""

# Remove volumes with confirmation
log_info "💾 AI LaunchKit Data Volumes"
echo "=========================================="
VOLUME_COUNT=$(docker volume ls -q | grep "^localai_" | wc -l)

if [ "$VOLUME_COUNT" -gt 0 ]; then
    echo "Found $VOLUME_COUNT data volumes:"
    docker volume ls --filter "name=localai_" --format "  - {{.Name}}"
    echo ""
    log_warning "⚠️  Removing volumes will DELETE ALL DATA (workflows, databases, files)"
    
    if [ "$backup_choice" =~ ^[Nn]$ ]; then
        log_error "⚠️  You chose NOT to create a backup!"
    else
        log_success "✅ Backup was created in $BACKUP_DIR"
    fi
    
    echo ""
    read -p "Remove all data volumes? (yes/NO): " volume_confirm
    
    if [ "$volume_confirm" = "yes" ]; then
        log_info "Removing volumes..."
        docker volume ls -q | grep "^localai_" | xargs -r docker volume rm
        log_success "✅ Volumes removed"
    else
        log_info "Volumes preserved. You can remove them later with:"
        log_info "  docker volume ls | grep localai_"
        log_info "  docker volume rm localai_<volume_name>"
    fi
else
    log_info "No volumes to remove"
fi
echo ""

# Remove networks
log_info "🌐 Removing AI LaunchKit Networks"
echo "=========================================="
NETWORK_COUNT=$(docker network ls -q | xargs docker network inspect --format '{{.Name}} {{.Labels}}' 2>/dev/null | grep "localai" | wc -l || echo "0")

if [ "$NETWORK_COUNT" -gt 0 ]; then
    log_info "Removing networks..."
    docker network ls | grep localai | awk '{print $1}' | xargs -r docker network rm 2>/dev/null || true
    log_success "✅ Networks removed"
else
    log_info "No networks to remove"
fi
echo ""

# Remove unused images
log_info "🖼️  Cleaning Up Unused Images"
echo "=========================================="
read -p "Remove unused AI LaunchKit images? (Y/n): " image_confirm

if [[ ! "$image_confirm" =~ ^[Nn]$ ]]; then
    log_info "Removing unused images..."
    docker image prune -a -f --filter "label=com.docker.compose.project=localai" 2>/dev/null || true
    log_success "✅ Unused images removed"
else
    log_info "Images preserved"
fi
echo ""

# .env file management
log_info "📄 Configuration File Management"
echo "=========================================="
if [ -f "$ENV_FILE" ]; then
    read -p "Keep .env configuration file? (Y/n): " env_keep
    
    if [[ "$env_keep" =~ ^[Nn]$ ]]; then
        cp "$ENV_FILE" "$ENV_FILE.backup-$(date +%Y%m%d-%H%M%S)"
        rm "$ENV_FILE"
        log_info "✅ .env removed (backup created: .env.backup-*)"
    else
        log_info "✅ .env file preserved"
    fi
else
    log_info "No .env file found"
fi
echo ""

# Install or start Portainer if needed
log_info "🐳 Portainer Docker Management"
echo "=========================================="

if [ "$PORTAINER_INSTALLED" = false ]; then
    log_info "Installing Portainer for Docker management..."
    
    # Create Portainer volume if it doesn't exist
    docker volume create portainer_data 2>/dev/null || true
    
    # Install Portainer
    docker run -d \
        -p 9443:9443 \
        --name=portainer \
        --restart=always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer_data:/data \
        portainer/portainer-ce:latest
    
    log_success "✅ Portainer installed successfully!"
    log_info "   Access Portainer at: https://localhost:9443"
    log_info "   (Create admin account on first login)"
    
elif [ "$PORTAINER_RUNNING" = false ]; then
    log_info "Starting existing Portainer..."
    docker start portainer
    log_success "✅ Portainer started"
    log_info "   Access at: https://localhost:9443"
else
    log_success "✅ Portainer already running (port 9443)"
fi
echo ""

# Final report
echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║              ✅ AI LAUNCHKIT UNINSTALL COMPLETE                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

log_success "AI LaunchKit has been uninstalled from your system"
echo ""

# Summary of what was done
log_info "📋 Uninstall Summary"
echo "=========================================="
echo "✅ AI LaunchKit containers removed"
echo "✅ AI LaunchKit networks removed"

if [ "$volume_confirm" = "yes" ]; then
    echo "✅ AI LaunchKit data volumes removed"
else
    echo "⚠️  Data volumes preserved (remove manually if needed)"
fi

if [[ ! "$image_confirm" =~ ^[Nn]$ ]]; then
    echo "✅ Unused images cleaned up"
fi

if [ -f "$BACKUP_DIR/.env.backup" ]; then
    echo "✅ Backup created: $BACKUP_DIR"
fi

echo "✅ Portainer preserved/installed (port 9443)"
echo ""

log_info "🔧 What's Next?"
echo "=========================================="
echo "Docker Management:"
echo "  → Access Portainer: https://localhost:9443"
echo "  → View all containers: docker ps -a"
echo "  → View all volumes: docker volume ls"
echo ""

if [ "$volume_confirm" != "yes" ]; then
    echo "Manual Volume Cleanup (if needed):"
    echo "  → List volumes: docker volume ls | grep localai_"
    echo "  → Remove volume: docker volume rm localai_<volume_name>"
    echo "  → Remove all: docker volume ls -q | grep 'localai_' | xargs docker volume rm"
    echo ""
fi

if [ -f "$BACKUP_DIR/.env.backup" ]; then
    echo "Restore from Backup:"
    echo "  → Backup location: $BACKUP_DIR"
    echo "  → View backups: ls -lh $BACKUP_DIR"
    echo "  → Restore volume: docker run --rm -v localai_<name>:/dest -v $BACKUP_DIR:/backup alpine tar xzf /backup/<name>.tar.gz -C /dest"
    echo ""
fi

echo "Reinstall AI LaunchKit:"
echo "  → cd $PROJECT_ROOT"
echo "  → sudo bash ./scripts/install_local.sh"
echo ""

log_success "🎉 Uninstall process completed successfully!"

exit 0
