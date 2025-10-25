#!/bin/bash

set -e

# Source utilities
source "$(dirname "$0")/utils.sh"

# Get project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." &> /dev/null && pwd )"
ENV_FILE="$PROJECT_ROOT/.env"

# Check if perplexica is in COMPOSE_PROFILES
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

if [[ "$COMPOSE_PROFILES" == *"perplexica"* ]]; then
    log_info "Perplexica selected - Setting up Perplexica repository..."
    
    cd "$PROJECT_ROOT"
    
    # Clone Perplexica if not exists
    if [ ! -d "perplexica" ]; then
        log_info "Cloning Perplexica repository..."
        git clone https://github.com/ItzCrazyKns/Perplexica.git perplexica || {
            log_error "Failed to clone Perplexica repository"
            exit 1
        }
    else
        log_info "Perplexica repository already exists"
    fi
    
    # Configure Perplexica
    cd perplexica
    
    if [ ! -f "config.toml" ]; then
        # Try multiple config sources (Perplexica repo structure changes)
        if [ -f "sample.config.toml" ]; then
            log_info "Using sample.config.toml from Perplexica repository..."
            cp sample.config.toml config.toml
        elif [ -f "$PROJECT_ROOT/perplexica.config.toml" ]; then
            log_info "Using perplexica.config.toml from AI LaunchKit root..."
            cp "$PROJECT_ROOT/perplexica.config.toml" config.toml
        elif [ -f ".env.example" ]; then
            log_warning "sample.config.toml not found, Perplexica uses .env configuration now"
            log_info "Using .env.example as template..."
            cp .env.example .env
            # Configure .env instead
            sed -i 's|OLLAMA_API_URL=.*|OLLAMA_API_URL=http://ollama:11434|' .env
            sed -i 's|SEARXNG_API_URL=.*|SEARXNG_API_URL=http://searxng:8080|' .env
            log_success "Perplexica configured via .env"
            cd "$PROJECT_ROOT"
            exit 0
        else
            log_error "No configuration template found in Perplexica repository"
            log_warning "Perplexica repository structure may have changed"
            log_info "Skipping Perplexica configuration - service may not work correctly"
            log_info "You can configure manually later or report this issue"
            cd "$PROJECT_ROOT"
            exit 0  # Non-critical - continue installation
        fi
        
        log_info "Configuring Perplexica..."
        
        # Update Ollama API URL
        sed -i 's|API_URL = ""|API_URL = "http://ollama:11434"|' config.toml
        
        # Update SearXNG URL
        sed -i 's|SEARXNG = ""|SEARXNG = "http://searxng:8080"|' config.toml
        
        # If OpenAI API key exists in env, add it
        if [ -n "${OPENAI_API_KEY}" ]; then
            sed -i "/\[MODELS.OPENAI\]/,/^\[/ s|API_KEY = \"\"|API_KEY = \"${OPENAI_API_KEY}\"|" config.toml
            log_info "OpenAI API key configured for Perplexica"
        fi
        
        # If Anthropic API key exists in env, add it
        if [ -n "${ANTHROPIC_API_KEY}" ]; then
            sed -i "/\[MODELS.ANTHROPIC\]/,/^\[/ s|API_KEY = \"\"|API_KEY = \"${ANTHROPIC_API_KEY}\"|" config.toml
            log_info "Anthropic API key configured for Perplexica"
        fi
        
        # If Groq API key exists in env, add it
        if [ -n "${GROQ_API_KEY}" ]; then
            sed -i "/\[MODELS.GROQ\]/,/^\[/ s|API_KEY = \"\"|API_KEY = \"${GROQ_API_KEY}\"|" config.toml
            log_info "Groq API key configured for Perplexica"
        fi
        
        log_success "Perplexica configured successfully"
    else
        log_info "Perplexica config.toml already exists - skipping configuration"
    fi
    
    cd "$PROJECT_ROOT"
else
    log_info "Perplexica not selected - skipping setup"
fi

exit 0
