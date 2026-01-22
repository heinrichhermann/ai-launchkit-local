#!/bin/bash

# Cognee Setup Script for AI LaunchKit
# Prepares Cognee MCP Server with Ollama integration
#
# This script:
# 1. Checks if Cognee profile is enabled
# 2. Ensures required Ollama models are available
# 3. Enables Qdrant if not already enabled (required for Cognee)
#
# Documentation: docs/COGNEE_SETUP.md

set -e

# Source utilities if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/utils.sh" ]; then
    source "$SCRIPT_DIR/utils.sh"
else
    # Fallback logging functions
    log_info() { echo "[INFO] $1"; }
    log_success() { echo "[SUCCESS] $1"; }
    log_warning() { echo "[WARNING] $1"; }
    log_error() { echo "[ERROR] $1"; }
fi

log_info "========== Cognee Setup =========="

# Check if .env exists
if [ ! -f ".env" ]; then
    log_warning ".env file not found, skipping Cognee setup"
    exit 0
fi

# Check if cognee profile is enabled
if ! grep -q "cognee" .env 2>/dev/null; then
    log_info "Cognee profile not selected, skipping setup"
    exit 0
fi

log_info "Cognee profile detected, preparing setup..."

# Ensure required Ollama models are available
log_info "Checking Ollama models for Cognee..."

# Wait for Ollama to be ready
MAX_RETRIES=30
RETRY_COUNT=0
OLLAMA_PORT=${OLLAMA_PORT:-8021}

while ! curl -s "http://localhost:${OLLAMA_PORT}/api/tags" > /dev/null 2>&1; do
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        log_warning "Ollama not ready, models will be pulled on first Cognee start"
        break
    fi
    log_info "Waiting for Ollama... ($RETRY_COUNT/$MAX_RETRIES)"
    sleep 5
done

# Pull required models if Ollama is ready
if curl -s "http://localhost:${OLLAMA_PORT}/api/tags" > /dev/null 2>&1; then
    log_info "Pulling embedding model for Cognee (qwen3-embedding:8b)..."
    docker exec ollama ollama pull qwen3-embedding:8b || {
        log_warning "Failed to pull qwen3-embedding:8b"
        log_info "Alternative: Try 'nomic-embed-text:latest' if qwen3-embedding is unavailable"
    }
    
    # LLM model (same as Cipher)
    log_info "Verifying LLM model (qwen3:8b)..."
    docker exec ollama ollama pull qwen3:8b || {
        log_warning "Failed to pull qwen3:8b, will retry on first use"
    }
fi

# Enable Qdrant if not already enabled (required for Cognee)
if ! grep -q "qdrant" .env 2>/dev/null; then
    log_info "Enabling Qdrant (required for Cognee vector storage)..."
    
    # Check if COMPOSE_PROFILES exists
    if grep -q "COMPOSE_PROFILES=" .env; then
        # Add qdrant to existing profiles
        sed -i.bak 's/COMPOSE_PROFILES="\([^"]*\)"/COMPOSE_PROFILES="\1,qdrant"/' .env
    else
        # Add COMPOSE_PROFILES with qdrant
        echo 'COMPOSE_PROFILES="qdrant,cognee"' >> .env
    fi
    
    log_info "Qdrant profile added to COMPOSE_PROFILES"
fi

log_success "✅ Cognee setup complete!"
echo ""
log_info "Cognee MCP Server will be available at:"
log_info "  - SSE Endpoint: http://SERVER_IP:8120/sse"
log_info "  - HTTP Endpoint: http://SERVER_IP:8120/mcp"
log_info "  - Health Check: http://SERVER_IP:8120/health"
echo ""
log_info "If cognee-ui profile is enabled:"
log_info "  - Frontend: http://SERVER_IP:8122"
log_info "  - CORS Proxy: http://SERVER_IP:8123"
echo ""
log_info "For MCP client configuration, see: docs/COGNEE_SETUP.md"
