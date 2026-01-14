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

# Create data directory for persistent storage
mkdir -p "$CIPHER_DIR/data"
log_info "Created data directory: $CIPHER_DIR/data"

# Create memAgent directory if it doesn't exist
mkdir -p "$CIPHER_DIR/memAgent"

# Create cipher.yml configuration for Ollama + Qdrant
log_info "Creating Cipher agent configuration..."

cat > "$CIPHER_DIR/memAgent/cipher.yml" << 'EOF'
# Cipher Agent Configuration for AI LaunchKit
# Uses Ollama for LLM and Qdrant for vector storage
# Documentation: https://github.com/campfirein/cipher

name: "AI LaunchKit Cipher Agent"
description: "Memory-powered AI assistant integrated with local Ollama and Qdrant"
version: "1.0.0"

# LLM Configuration - Use Ollama (local)
llm:
  provider: "ollama"
  model: "qwen2.5:7b-instruct-q4_K_M"
  temperature: 0.7
  maxTokens: 4096
  # Fallback models if primary is not available
  fallbackModels:
    - "llama3.2:3b"
    - "mistral:7b"

# Embedding Configuration - Use Ollama with nomic-embed-text
embedding:
  provider: "ollama"
  model: "nomic-embed-text"
  dimensions: 768

# Memory Configuration
memory:
  enabled: true
  type: "long-term"
  
  # Vector Store - Qdrant (AI LaunchKit)
  vectorStore:
    type: "qdrant"
    collection: "cipher_knowledge"
    # Distance metric for similarity search
    distance: "Cosine"
  
  # Maximum memories to retrieve per query
  maxResults: 10
  
  # Minimum similarity score to include memory
  minScore: 0.7

# Reflection Memory (Self-improvement)
reflection:
  enabled: true
  collection: "cipher_reflection"
  # How often to reflect on conversations
  interval: 5

# Tools available to the agent
tools:
  - name: "web_search"
    enabled: true
    config:
      engine: "duckduckgo"
      maxResults: 5
      safeSearch: "moderate"
  
  - name: "memory_search"
    enabled: true
    config:
      maxResults: 10
  
  - name: "memory_store"
    enabled: true
    config:
      autoStore: true
      minImportance: 0.5

# Chat History Configuration
chatHistory:
  enabled: true
  maxMessages: 100
  # Store in PostgreSQL via CIPHER_PG_URL environment variable

# System Prompt
systemPrompt: |
  You are a helpful AI assistant with persistent memory capabilities.
  You can remember information from previous conversations and learn over time.
  You are running locally on AI LaunchKit with Ollama as your LLM backend.
  
  Key capabilities:
  - Store and retrieve knowledge from your vector memory (Qdrant)
  - Search the web for current information (DuckDuckGo)
  - Learn and improve from interactions through reflection
  - Maintain conversation context across sessions
  
  Guidelines:
  - Be helpful, accurate, and acknowledge when you're uncertain
  - When storing memories, focus on important facts and user preferences
  - Use web search for current events or information you don't have
  - Reference previous conversations when relevant
  
  You have access to the following AI LaunchKit services:
  - n8n (workflow automation) at port 8000
  - Ollama (local LLM) at port 8021
  - Qdrant (vector database) at port 8026
  - PostgreSQL (database) at port 8001

# MCP (Model Context Protocol) Configuration
mcp:
  enabled: true
  transport: "sse"
  # SSE endpoint will be available at /mcp/sse

# Rate Limiting
rateLimit:
  enabled: false
  maxRequests: 100
  windowMs: 60000
EOF

log_success "Cipher configuration created: $CIPHER_DIR/memAgent/cipher.yml"

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
log_info "   - Agent Config: $CIPHER_DIR/memAgent/cipher.yml"
log_info "   - Data Directory: $CIPHER_DIR/data"
log_info "   - LLM Provider: Ollama (qwen2.5:7b-instruct-q4_K_M)"
log_info "   - Vector Store: Qdrant (cipher_knowledge collection)"
log_info "   - Chat History: PostgreSQL (cipher database)"
log_info ""
log_info "📡 Cipher will be accessible at:"
log_info "   - Web UI: http://SERVER_IP:3001"
log_info "   - API: http://SERVER_IP:3000"
log_info "   - MCP SSE: http://SERVER_IP:3000/mcp/sse"
log_info ""

exit 0