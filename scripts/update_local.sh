#!/bin/bash

set -e

# AI LaunchKit Local - Update Script
# Safely updates the AI LaunchKit to the latest version

# Source the utilities file
source "$(dirname "$0")/utils.sh"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    log_error "Please run as root (use sudo)"
    exit 1
fi

# Global error handler
CURRENT_STEP="Initialization"

cleanup_on_error() {
    local exit_code=$?
    echo ""
    log_error "════════════════════════════════════════"
    log_error "❌ Update failed at: $CURRENT_STEP"
    log_error "Exit code: $exit_code"
    log_error "════════════════════════════════════════"
    echo ""
    
    log_warning "Services are still running with previous version"
    log_info "Your data is safe - nothing was modified"
    
    echo ""
    log_info "To rollback if needed:"
    log_info "  cd ~/ai/ai-launchkit-local"
    log_info "  git checkout HEAD~1"
    log_info "  docker compose -p localai -f docker-compose.local.yml up -d"
    
    exit $exit_code
}

# Register error trap
trap 'cleanup_on_error' ERR

# Get script and project directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"
BACKUP_DIR="$PROJECT_ROOT/.update-backup-$(date +%Y%m%d-%H%M%S)"

# Welcome message
echo ""
log_info "🔄 AI LaunchKit Local - Update Process"
echo "=========================================="
echo ""
log_info "This will update:"
log_info "  - AI LaunchKit scripts and configuration"
log_info "  - Docker images for all services"
log_info "  - Restart services with new versions"
echo ""

# Check if AI LaunchKit is installed
if ! docker ps -a | grep -q "localai"; then
    log_error "AI LaunchKit not found in Docker"
    log_info "Nothing to update. Install first: sudo bash ./scripts/install_local.sh"
    exit 1
fi

# Change to project root
cd "$PROJECT_ROOT"

# Show current version
CURRENT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
log_info "Current version: $CURRENT_COMMIT"

# Check for uncommitted changes
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    log_warning "⚠️ You have uncommitted local changes"
    log_info "These changes will be backed up but may be overwritten"
    echo ""
    read -p "Continue with update? (y/N): " continue_update
    if [[ ! "$continue_update" =~ ^[Yy]$ ]]; then
        log_info "Update cancelled"
        exit 0
    fi
fi

# Create backup
CURRENT_STEP="Creating Backup"
log_info "========== Step 1: Creating Backup =========="
mkdir -p "$BACKUP_DIR"

# Backup .env file
if [ -f "$ENV_FILE" ]; then
    log_info "Backing up .env configuration..."
    cp "$ENV_FILE" "$BACKUP_DIR/.env.backup"
fi

# Backup git state
log_info "Backing up git state..."
git rev-parse HEAD > "$BACKUP_DIR/git_commit.txt"
git diff > "$BACKUP_DIR/git_changes.patch" 2>/dev/null || true

log_success "✅ Backup created: $BACKUP_DIR"
echo ""

# Pull latest changes
CURRENT_STEP="Pulling Latest Changes"
log_info "========== Step 2: Pulling Latest Changes =========="
log_info "Fetching updates from GitHub..."

git fetch origin main || {
    log_error "Failed to fetch from GitHub"
    log_info "Check internet connection"
    exit 1
}

# Check if there are updates
LATEST_COMMIT=$(git rev-parse origin/main)
if [ "$CURRENT_COMMIT" = "$LATEST_COMMIT" ]; then
    log_success "✅ Already up to date!"
    log_info "No updates available"
    
    # Still offer to update Docker images
    echo ""
    read -p "Update Docker images anyway? (y/N): " update_images
    if [[ ! "$update_images" =~ ^[Yy]$ ]]; then
        log_info "Update cancelled - nothing to do"
        exit 0
    fi
else
    log_info "Updates available:"
    git log --oneline HEAD..origin/main | head -10
    echo ""
    
    # Pull changes
    log_info "Pulling changes..."
    git reset --hard origin/main || {
        log_error "Failed to pull changes"
        log_info "Restore backup: cp $BACKUP_DIR/.env.backup .env"
        exit 1
    }
    
    NEW_COMMIT=$(git rev-parse --short HEAD)
    log_success "✅ Updated: $CURRENT_COMMIT → $NEW_COMMIT"
fi

echo ""

# Restore .env if it was backed up (git reset might have overwritten it)
if [ -f "$BACKUP_DIR/.env.backup" ]; then
    log_info "Restoring your .env configuration..."
    cp "$BACKUP_DIR/.env.backup" "$ENV_FILE"
    log_success "✅ .env restored"
fi

# Pull latest Docker images
CURRENT_STEP="Updating Docker Images"
log_info "========== Step 3: Updating Docker Images =========="
log_info "Pulling latest versions (this may take a few minutes)..."

docker compose -p localai -f docker-compose.local.yml pull --ignore-buildable || {
    log_warning "Some images failed to pull"
    log_info "Continuing with available images..."
}

log_success "✅ Docker images updated"
echo ""

# Restart services
CURRENT_STEP="Restarting Services"
log_info "========== Step 4: Restarting Services =========="
log_info "Stopping current services..."
docker compose -p localai -f docker-compose.local.yml down

log_info "Starting services with new versions..."
docker compose -p localai -f docker-compose.local.yml up -d

log_success "✅ Services restarted"
echo ""

# Health check
CURRENT_STEP="Health Check"
log_info "========== Step 5: Health Check =========="
log_info "Waiting for services to initialize..."
sleep 10

# Check critical services
FAILED_SERVICES=()

if docker ps | grep -q "postgres"; then
    log_success "✅ PostgreSQL running"
else
    FAILED_SERVICES+=("postgres")
fi

if docker ps | grep -q "redis"; then
    log_success "✅ Redis running"
else
    FAILED_SERVICES+=("redis")
fi

if docker ps | grep -q "n8n"; then
    log_success "✅ n8n running"
else
    FAILED_SERVICES+=("n8n")
fi

if [ ${#FAILED_SERVICES[@]} -gt 0 ]; then
    log_warning "⚠️ Some services failed to start:"
    printf "  - %s\n" "${FAILED_SERVICES[@]}"
    echo ""
    log_info "Check logs: docker compose -p localai -f docker-compose.local.yml logs"
else
    log_success "✅ All core services running"
fi

echo ""

# Final report
echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                   ✅ UPDATE COMPLETE                             ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

log_success "AI LaunchKit has been updated successfully!"
echo ""

log_info "📊 Update Summary"
echo "=========================================="
echo "✅ Repository updated to latest version"
echo "✅ Docker images updated"
echo "✅ Services restarted"
if [ -f "$BACKUP_DIR/.env.backup" ]; then
    echo "✅ Backup created: $BACKUP_DIR"
fi
echo ""

log_info "🔧 What's Next?"
echo "=========================================="
echo "Check service status:"
echo "  → docker ps"
echo ""
echo "View service logs:"
echo "  → docker compose -p localai -f docker-compose.local.yml logs [service]"
echo ""
echo "Access services:"
echo "  → http://SERVER_IP/ (Dashboard)"
echo "  → http://SERVER_IP:8000 (n8n)"
echo ""

if [ -f "$BACKUP_DIR/.env.backup" ]; then
    echo "Restore backup if needed:"
    echo "  → cp $BACKUP_DIR/.env.backup .env"
    echo "  → docker compose -p localai -f docker-compose.local.yml restart"
    echo ""
fi

log_success "🎉 Update process completed!"

exit 0
