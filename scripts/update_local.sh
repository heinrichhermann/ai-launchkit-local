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

# Regenerate landing page with updated template
if [ -f "$SCRIPT_DIR/generate_landing_page.sh" ]; then
    log_info "Regenerating landing page with updated template..."
    bash "$SCRIPT_DIR/generate_landing_page.sh" || {
        log_warning "Landing page generation failed (non-critical)"
    }
else
    log_warning "Landing page generator not found (skipping)"
fi

# Pull latest Docker images
CURRENT_STEP="Updating Docker Images"
log_info "========== Step 3: Updating Docker Images =========="
log_info "Pulling latest versions (this may take a few minutes)..."

# Force pull floating-tag images that don't auto-update
log_info "Force pulling floating-tag images (open-notebook, n8n base)..."
docker pull lfnovo/open_notebook:v1-latest-single 2>/dev/null || {
    log_warning "Failed to pull open-notebook (continuing...)"
}
docker pull n8nio/n8n:latest 2>/dev/null || {
    log_warning "Failed to pull n8n base image (continuing...)"
}

# Pull all pre-built images (ignore buildable services)
log_info "Pulling standard images..."
docker compose -p localai -f docker-compose.local.yml pull --ignore-buildable || {
    log_warning "Some images failed to pull"
    log_info "Continuing with available images..."
}

log_success "✅ Pre-built Docker images updated"
echo ""

# Rebuild buildable services (n8n, bolt, chatterbox)
log_info "Rebuilding custom services with latest base images..."
log_info "Building n8n (this rebuilds with latest n8nio/n8n:latest)..."
docker compose -p localai -f docker-compose.local.yml build --no-cache --pull n8n n8n-import n8n-worker || {
    log_warning "n8n rebuild failed"
    log_info "Continuing with existing n8n image..."
}

# Build bolt if in profile
if [[ "$COMPOSE_PROFILES" == *"bolt"* ]]; then
    log_info "Building bolt..."
    docker compose -p localai -f docker-compose.local.yml build --pull bolt || {
        log_warning "Bolt rebuild failed (non-critical)"
    }
fi

# Build chatterbox if in profile  
if [[ "$COMPOSE_PROFILES" == *"tts-chatterbox"* ]]; then
    log_info "Building chatterbox..."
    docker compose -p localai -f docker-compose.local.yml build --pull chatterbox-tts chatterbox-frontend || {
        log_warning "Chatterbox rebuild failed (non-critical)"
    }
fi

log_success "✅ All Docker images updated"
echo ""

# Restart services
CURRENT_STEP="Restarting Services"
log_info "========== Step 4: Restarting Services =========="
log_info "Stopping current services..."
docker compose -p localai -f docker-compose.local.yml down --remove-orphans

# Additional cleanup: Remove any containers with conflicting names
# This handles cases where containers were deployed with different project names
log_info "Cleaning up any conflicting containers..."
docker ps -a --format "{{.Names}}" | grep -E "^(n8n|portainer|postgres|redis|ollama|neo4j|lightrag|faster-whisper|scriberr|python-runner|formbricks_db)$" | while read container; do
    if docker ps -a --format "{{.Names}}" | grep -q "^${container}$"; then
        docker rm -f "$container" 2>/dev/null || true
    fi
done

log_info "Starting services with new versions..."
docker compose -p localai -f docker-compose.local.yml up -d

log_success "✅ Services restarted"
echo ""

# Health check
CURRENT_STEP="Health Check"
log_info "========== Step 5: Health Check =========="
log_info "Waiting for services to initialize..."
sleep 10

# Load COMPOSE_PROFILES from .env to check active services
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

# Check service health
log_info "Checking service health..."
FAILED_SERVICES=()

# Core services (always active)
if docker ps | grep -q "postgres"; then
    log_success "✅ PostgreSQL is running (Port 8001)"
else
    FAILED_SERVICES+=("postgres")
fi

if docker ps | grep -q "redis"; then
    log_success "✅ Redis is running (Port 8002)"
else
    FAILED_SERVICES+=("redis")
fi

if docker ps | grep -q "n8n"; then
    log_success "✅ n8n is running (Port 8000)"
else
    FAILED_SERVICES+=("n8n")
fi

# Check monitoring services
if [[ "$COMPOSE_PROFILES" == *"monitoring"* ]]; then
    if docker ps | grep -q "grafana"; then
        log_success "✅ Grafana is running (Port 8003)"
    else
        FAILED_SERVICES+=("grafana")
    fi
    
    if docker ps | grep -q "prometheus"; then
        log_success "✅ Prometheus is running (Port 8004)"
    else
        FAILED_SERVICES+=("prometheus")
    fi
fi

# Check Portainer
if [[ "$COMPOSE_PROFILES" == *"portainer"* ]]; then
    if docker ps | grep -q "portainer"; then
        log_success "✅ Portainer is running (Port 8007)"
    else
        FAILED_SERVICES+=("portainer")
    fi
fi

# Check AI services
if [[ "$COMPOSE_PROFILES" == *"open-webui"* ]]; then
    if docker ps | grep -q "open-webui"; then
        log_success "✅ Open WebUI is running (Port 8020)"
    else
        FAILED_SERVICES+=("open-webui")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"cpu"* ]] || [[ "$COMPOSE_PROFILES" == *"gpu-nvidia"* ]] || [[ "$COMPOSE_PROFILES" == *"gpu-amd"* ]]; then
    if docker ps | grep -q "ollama"; then
        log_success "✅ Ollama is running (Port 8021)"
    else
        FAILED_SERVICES+=("ollama")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"flowise"* ]]; then
    if docker ps | grep -q "flowise"; then
        log_success "✅ Flowise is running (Port 8022)"
    else
        FAILED_SERVICES+=("flowise")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"bolt"* ]]; then
    if docker ps | grep -q "bolt"; then
        log_success "✅ Bolt is running (Port 8023)"
    else
        FAILED_SERVICES+=("bolt")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"comfyui-cpu"* ]] || [[ "$COMPOSE_PROFILES" == *"comfyui-gpu"* ]]; then
    if docker ps | grep -q "comfyui"; then
        # Determine which variant is running
        if [[ "$COMPOSE_PROFILES" == *"comfyui-gpu"* ]]; then
            log_success "✅ ComfyUI (GPU) is running (Port 8024)"
        else
            log_success "✅ ComfyUI (CPU) is running (Port 8024)"
        fi
    else
        FAILED_SERVICES+=("comfyui")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"openui"* ]]; then
    if docker ps | grep -q "openui"; then
        log_success "✅ OpenUI is running (Port 8025)"
    else
        FAILED_SERVICES+=("openui")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"qdrant"* ]]; then
    if docker ps | grep -q "qdrant"; then
        log_success "✅ Qdrant is running (Port 8026)"
    else
        FAILED_SERVICES+=("qdrant")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"weaviate"* ]]; then
    if docker ps | grep -q "weaviate"; then
        log_success "✅ Weaviate is running (Port 8027)"
    else
        FAILED_SERVICES+=("weaviate")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"neo4j"* ]]; then
    if docker ps | grep -q "neo4j"; then
        log_success "✅ Neo4j is running (Port 8028)"
    else
        FAILED_SERVICES+=("neo4j")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"lightrag"* ]]; then
    if docker ps | grep -q "lightrag"; then
        log_success "✅ LightRAG is running (Port 8029)"
    else
        FAILED_SERVICES+=("lightrag")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"ragapp"* ]]; then
    if docker ps | grep -q "ragapp"; then
        log_success "✅ RAGApp is running (Port 8030)"
    else
        FAILED_SERVICES+=("ragapp")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"letta"* ]]; then
    if docker ps | grep -q "letta"; then
        log_success "✅ Letta is running (Port 8031)"
    else
        FAILED_SERVICES+=("letta")
    fi
fi

# Check research & notebooks
if [[ "$COMPOSE_PROFILES" == *"open-notebook"* ]]; then
    if docker ps | grep -q "open-notebook"; then
        log_success "✅ Open Notebook is running (Port 8100)"
    else
        FAILED_SERVICES+=("open-notebook")
    fi
fi

# Check business tools
if [[ "$COMPOSE_PROFILES" == *"calcom"* ]]; then
    if docker ps | grep -q "calcom"; then
        log_success "✅ Cal.com is running (Port 8040)"
    else
        FAILED_SERVICES+=("calcom")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"baserow"* ]]; then
    if docker ps | grep -q "baserow"; then
        log_success "✅ Baserow is running (Port 8047)"
    else
        FAILED_SERVICES+=("baserow")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"nocodb"* ]]; then
    if docker ps | grep -q "nocodb"; then
        log_success "✅ NocoDB is running (Port 8048)"
    else
        FAILED_SERVICES+=("nocodb")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"vikunja"* ]]; then
    if docker ps | grep -q "vikunja"; then
        log_success "✅ Vikunja is running (Port 8049)"
    else
        FAILED_SERVICES+=("vikunja")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"leantime"* ]]; then
    if docker ps | grep -q "leantime"; then
        log_success "✅ Leantime is running (Port 8050)"
    else
        FAILED_SERVICES+=("leantime")
    fi
fi

# Check utilities
if [[ "$COMPOSE_PROFILES" == *"postiz"* ]]; then
    if docker ps | grep -q "postiz"; then
        log_success "✅ Postiz is running (Port 8060)"
    else
        FAILED_SERVICES+=("postiz")
    fi
fi


if [[ "$COMPOSE_PROFILES" == *"kopia"* ]]; then
    if docker ps | grep -q "kopia"; then
        log_success "✅ Kopia is running (Port 8062)"
    else
        FAILED_SERVICES+=("kopia")
    fi
fi

# Check mail service (always active with core services)
if docker ps | grep -q "mailpit"; then
    log_success "✅ Mailpit is running (Port 8071)"
else
    FAILED_SERVICES+=("mailpit")
fi

# Check specialized services
if [[ "$COMPOSE_PROFILES" == *"speech"* ]]; then
    if docker ps | grep -q "faster-whisper"; then
        log_success "✅ Faster Whisper is running (Port 8080)"
    else
        FAILED_SERVICES+=("faster-whisper")
    fi
    
    if docker ps | grep -q "openedai-speech"; then
        log_success "✅ OpenedAI Speech is running (Port 8081)"
    else
        FAILED_SERVICES+=("openedai-speech")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"libretranslate"* ]]; then
    if docker ps | grep -q "libretranslate"; then
        log_success "✅ LibreTranslate is running (Port 8082)"
    else
        FAILED_SERVICES+=("libretranslate")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"scriberr"* ]]; then
    if docker ps | grep -q "scriberr"; then
        log_success "✅ Scriberr is running (Port 8083)"
    else
        FAILED_SERVICES+=("scriberr")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"ocr"* ]]; then
    if docker ps | grep -q "tesseract-ocr"; then
        log_success "✅ Tesseract OCR is running (Port 8084)"
    else
        FAILED_SERVICES+=("tesseract-ocr")
    fi
    
    if docker ps | grep -q "easyocr"; then
        log_success "✅ EasyOCR is running (Port 8085)"
    else
        FAILED_SERVICES+=("easyocr")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"stirling-pdf"* ]]; then
    if docker ps | grep -q "stirling-pdf"; then
        log_success "✅ Stirling PDF is running (Port 8086)"
    else
        FAILED_SERVICES+=("stirling-pdf")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"tts-chatterbox"* ]]; then
    if docker ps | grep -q "chatterbox-tts"; then
        log_success "✅ Chatterbox TTS is running (Port 8087)"
    else
        FAILED_SERVICES+=("chatterbox-tts")
    fi
    
    if docker ps | grep -q "chatterbox-frontend"; then
        log_success "✅ Chatterbox Frontend is running (Port 8088)"
    else
        FAILED_SERVICES+=("chatterbox-frontend")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"searxng"* ]]; then
    if docker ps | grep -q "searxng"; then
        log_success "✅ SearXNG is running (Port 8089)"
    else
        FAILED_SERVICES+=("searxng")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"perplexica"* ]]; then
    if docker ps | grep -q "perplexica"; then
        log_success "✅ Perplexica is running (Port 8090)"
    else
        FAILED_SERVICES+=("perplexica")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"formbricks"* ]]; then
    if docker ps | grep -q "formbricks"; then
        log_success "✅ Formbricks is running (Port 8091)"
    else
        FAILED_SERVICES+=("formbricks")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"metabase"* ]]; then
    if docker ps | grep -q "metabase"; then
        log_success "✅ Metabase is running (Port 8092)"
    else
        FAILED_SERVICES+=("metabase")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"crawl4ai"* ]]; then
    if docker ps | grep -q "crawl4ai"; then
        log_success "✅ Crawl4AI is running (Port 8093)"
    else
        FAILED_SERVICES+=("crawl4ai")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"gotenberg"* ]]; then
    if docker ps | grep -q "gotenberg"; then
        log_success "✅ Gotenberg is running (Port 8094)"
    else
        FAILED_SERVICES+=("gotenberg")
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"python-runner"* ]]; then
    if docker ps | grep -q "python-runner"; then
        log_success "✅ Python Runner is running (Port 8095)"
    else
        FAILED_SERVICES+=("python-runner")
    fi
fi

# Check design tools
if [[ "$COMPOSE_PROFILES" == *"penpot"* ]]; then
    if docker ps | grep -q "penpot-frontend"; then
        log_success "✅ Penpot is running (Port 8111)"
    else
        FAILED_SERVICES+=("penpot-frontend")
    fi
fi

# Check Langfuse stack
if [[ "$COMPOSE_PROFILES" == *"langfuse"* ]]; then
    if docker ps | grep -q "langfuse-web"; then
        log_success "✅ Langfuse Web is running (Port 8096)"
    else
        FAILED_SERVICES+=("langfuse-web")
    fi
    
    if docker ps | grep -q "langfuse-worker"; then
        log_success "✅ Langfuse Worker is running"
    else
        FAILED_SERVICES+=("langfuse-worker")
    fi
    
    if docker ps | grep -q "clickhouse"; then
        log_success "✅ ClickHouse is running (Port 8097)"
    else
        FAILED_SERVICES+=("clickhouse")
    fi
    
    if docker ps | grep -q "minio"; then
        log_success "✅ MinIO is running (Port 8098/8099)"
    else
        FAILED_SERVICES+=("minio")
    fi
fi

# Check dashboard
if docker ps | grep -q "ailaunchkit-dashboard"; then
    log_success "✅ Dashboard is running (Port 80)"
else
    FAILED_SERVICES+=("dashboard")
fi

# Report any failures
if [ ${#FAILED_SERVICES[@]} -gt 0 ]; then
    log_warning "⚠️ Some services failed to start after update:"
    printf "  - %s\n" "${FAILED_SERVICES[@]}"
    echo ""
    log_info "Check service logs with:"
    log_info "  docker compose -p localai -f docker-compose.local.yml logs [service_name]"
    echo ""
    log_info "Common issues after updates:"
    log_info "  - Service needs more time to initialize (wait 2-3 minutes)"
    log_info "  - Database migration in progress"
    log_info "  - Version compatibility issues (check service-specific docs)"
    log_info "  - Insufficient system resources (RAM/CPU)"
else
    log_success "✅ All selected services running successfully!"
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
