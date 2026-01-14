#!/bin/bash

# Cipher Setup Script - Clone repository and configure agent
# Part of AI LaunchKit Local - Cipher Integration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CIPHER_DIR="$PROJECT_ROOT/cipher"
ENV_FILE="$PROJECT_ROOT/.env"

# Source the utilities file
source "$SCRIPT_DIR/utils.sh"

# Load environment variables
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

# Check if cipher is in selected profiles
if [[ ! "$COMPOSE_PROFILES" == *"cipher"* ]]; then
    log_info "Cipher not selected, skipping setup"
    exit 0
fi

log_info "========== Setting up Cipher =========="

# Clone Cipher repository if not exists
if [ ! -d "$CIPHER_DIR" ]; then
    log_info "Cloning Cipher repository..."
    git clone https://github.com/campfirein/cipher.git "$CIPHER_DIR" || {
        log_error "Failed to clone Cipher repository"
        exit 1
    }
    log_success "Cipher repository cloned successfully"
else
    log_info "Cipher directory already exists, pulling latest..."
    cd "$CIPHER_DIR" && git pull origin main || {
        log_warning "Failed to pull latest changes (continuing with existing version)"
    }
fi

# Create data directory for persistent storage (mounted as /app/.cipher)
# This is where Cipher stores SQLite backup and other data
mkdir -p "$CIPHER_DIR/data"
log_info "Created data directory: $CIPHER_DIR/data (mounted as /app/.cipher)"

# Create empty SQLite backup file for volume mount
# Cipher hardcodes this path to /app/cipher-backup.db
if [ ! -f "$CIPHER_DIR/data/cipher-backup.db" ]; then
    touch "$CIPHER_DIR/data/cipher-backup.db"
    log_info "Created SQLite backup file: $CIPHER_DIR/data/cipher-backup.db"
fi

# Note: Cipher uses environment variables for configuration
# No YAML config file needed - all settings are in docker-compose.local.yml
# See: https://github.com/campfirein/cipher/blob/main/docs/configuration.md
log_info "Cipher configuration is done via environment variables in docker-compose"

# Verify required services will be available
log_info "Verifying service dependencies..."

MISSING_DEPS=""

# Check if qdrant is in profiles (should be auto-added by wizard)
if [[ ! "$COMPOSE_PROFILES" == *"qdrant"* ]]; then
    MISSING_DEPS="$MISSING_DEPS qdrant"
fi

# Check if ollama is in profiles (cpu, gpu-nvidia, or gpu-amd)
if [[ ! "$COMPOSE_PROFILES" == *"cpu"* ]] && [[ ! "$COMPOSE_PROFILES" == *"gpu-nvidia"* ]] && [[ ! "$COMPOSE_PROFILES" == *"gpu-amd"* ]]; then
    MISSING_DEPS="$MISSING_DEPS ollama"
fi

if [ -n "$MISSING_DEPS" ]; then
    log_warning "⚠️ Missing dependencies for Cipher:$MISSING_DEPS"
    log_warning "Cipher requires Qdrant and Ollama to function properly"
    log_info "Please ensure these services are selected in your COMPOSE_PROFILES"
fi

echo ""
log_success "✅ Cipher setup completed!"
log_info ""
log_info "📋 Cipher Configuration Summary:"
log_info "   - Repository: $CIPHER_DIR"
log_info "   - Data Directory: $CIPHER_DIR/data"
log_info "   - Configuration: Environment variables (docker-compose.local.yml)"
log_info "   - LLM Provider: Ollama (via OLLAMA_BASE_URL)"
log_info "   - Vector Store: Qdrant (via VECTOR_STORE_URL)"
log_info "   - Chat History: PostgreSQL (via CIPHER_PG_URL)"
log_info ""
log_info "📡 Cipher will be accessible at:"
log_info "   - Web UI: http://SERVER_IP:3001"
log_info "   - API: http://SERVER_IP:3000"
log_info "   - MCP SSE: http://SERVER_IP:3000/mcp/sse"
log_info ""

exit 0