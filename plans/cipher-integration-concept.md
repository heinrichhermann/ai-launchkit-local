# Cipher Integration Concept for AI LaunchKit Local

## Executive Summary

This document outlines the integration plan for **Cipher** (a memory-powered AI agent framework) into **AI LaunchKit Local**. Cipher will use the standard ports 3000/3001 (outside the 8xxx schema) and integrate with existing Qdrant and Ollama services.

---

## 1. Cipher Overview

### What is Cipher?
Cipher is an open-source memory-powered AI agent framework that provides:
- **Persistent Memory**: Long-term knowledge retention across sessions
- **Multi-Provider Support**: OpenAI, Anthropic, Ollama, Groq, etc.
- **Vector Store Integration**: Qdrant, Milvus, PGVector, in-memory
- **Knowledge Graph**: Optional Neo4j integration
- **MCP Integration**: Model Context Protocol via SSE transport
- **REST API**: Full API for programmatic access
- **Web UI**: Optional Next.js-based user interface

### Cipher Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                      Cipher Container                        │
│  ┌─────────────────┐  ┌─────────────────┐                   │
│  │   REST API      │  │   Next.js UI    │                   │
│  │   (Port 3000)   │  │   (Port 3001)   │                   │
│  └────────┬────────┘  └────────┬────────┘                   │
│           │                    │                             │
│           └────────┬───────────┘                             │
│                    │                                         │
│           ┌────────▼────────┐                               │
│           │   cipher.yml    │ ◄─── Agent Configuration      │
│           └────────┬────────┘                               │
│                    │                                         │
│    ┌───────────────┼───────────────┐                        │
│    │               │               │                        │
│    ▼               ▼               ▼                        │
│ ┌──────┐      ┌────────┐     ┌─────────┐                   │
│ │Ollama│      │ Qdrant │     │PostgreSQL│                  │
│ │(LLM) │      │(Vector)│     │(History) │                  │
│ └──────┘      └────────┘     └─────────┘                   │
└─────────────────────────────────────────────────────────────┘
```

### Key Requirements
1. **At least one API key required**: OpenAI or Anthropic (can be dummy for Ollama-only)
2. **Vector Store**: Uses Qdrant (already in AI LaunchKit on port 8026)
3. **LLM Provider**: Uses Ollama (already in AI LaunchKit on port 8021)
4. **Chat History**: Uses PostgreSQL (already in AI LaunchKit on port 8001)

---

## 2. AI LaunchKit Integration Pattern

### Port Schema Analysis
AI LaunchKit uses a structured port schema:
- **Core Services**: 8000-8019 (n8n, postgres, redis, grafana, etc.)
- **AI Services**: 8020-8039 (open-webui, ollama, flowise, etc.)
- **Learning Tools**: 8040-8050 (calcom, baserow, nocodb, etc.)
- **Utilities**: 8060-8079 (postiz, kopia, mail, etc.)
- **Specialized**: 8080-8099 (whisper, TTS, OCR, etc.)
- **Research**: 8100-8110 (open-notebook)
- **Design**: 8111-8116 (penpot)

### Decision: Use Standard Cipher Ports
**Ports 3000 and 3001** will be used for Cipher because:
1. User explicitly requested standard Cipher ports
2. Avoids port remapping complexity that caused previous issues
3. Cipher's internal Next.js UI proxies to 3001, not 3000 - changing ports breaks this
4. Clean separation from 8xxx schema (easy to identify as external tool)

### Profile-Based Activation
Following AI LaunchKit pattern, Cipher will use:
```bash
COMPOSE_PROFILES="cipher"
```

---

## 3. Integration Components

### 3.1 Docker Service Definition

Add to `docker-compose.local.yml`:

```yaml
# ============================================================================
# CIPHER - Memory-Powered AI Agent (Ports 3000-3001)
# ============================================================================

cipher:
  build:
    context: ./cipher
    args:
      - BUILD_UI=true
  container_name: cipher
  profiles: ["cipher"]
  restart: unless-stopped
  ports:
    - "3000:3000"  # API + MCP SSE endpoint
    - "3001:3001"  # Web UI
  environment:
    # LLM Provider - Ollama (local)
    - OLLAMA_BASE_URL=http://ollama:11434
    
    # Dummy API key for Ollama-only operation
    # Cipher requires at least one API key even if not used
    - OPENAI_API_KEY=${CIPHER_OPENAI_API_KEY:-sk-dummy-for-ollama-only}
    
    # Vector Store - Qdrant (AI LaunchKit)
    - VECTOR_STORE_TYPE=qdrant
    - VECTOR_STORE_URL=http://qdrant:6333
    - VECTOR_STORE_API_KEY=${QDRANT_API_KEY}
    - VECTOR_STORE_COLLECTION=cipher_knowledge
    - VECTOR_STORE_DIMENSION=1536
    
    # Chat History - PostgreSQL (AI LaunchKit)
    - CIPHER_MULTI_BACKEND=1
    - CIPHER_PG_URL=postgres://postgres:${POSTGRES_PASSWORD}@postgres:5432/cipher
    - STORAGE_DATABASE_TYPE=postgres
    
    # Application Settings
    - NODE_ENV=production
    - CIPHER_LOG_LEVEL=info
    - REDACT_SECRETS=true
    
    # Memory Configuration
    - SEARCH_MEMORY_TYPE=both
    - DISABLE_REFLECTION_MEMORY=false
    
    # Web Search (optional)
    - WEB_SEARCH_ENABLE=true
    - WEB_SEARCH_ENGINE=duckduckgo
    
    # Embedding - use Ollama
    - EMBEDDING_MODEL=nomic-embed-text
    - OLLAMA_EMBEDDING=true
  volumes:
    - ./cipher/memAgent:/app/memAgent:ro
    - ./cipher/data:/app/data
  depends_on:
    cipher-init:
      condition: service_completed_successfully
    postgres:
      condition: service_healthy
  networks:
    - ailaunchkit
  healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
    interval: 30s
    timeout: 10s
    retries: 5
    start_period: 60s

cipher-init:
  image: postgres:17-alpine
  container_name: cipher-init
  profiles: ["cipher"]
  depends_on:
    postgres:
      condition: service_healthy
  environment:
    PGPASSWORD: ${POSTGRES_PASSWORD}
  command: >
    sh -c "
    psql -h postgres -U postgres -c \"CREATE DATABASE cipher\" || true &&
    echo 'Cipher database ready'
    "
  restart: "no"
  networks:
    - ailaunchkit
```

### 3.2 Cipher Setup Script

Create `scripts/04d_setup_cipher.sh`:

```bash
#!/bin/bash

# Cipher Setup Script - Clone repository and configure agent

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CIPHER_DIR="$PROJECT_ROOT/cipher"

source "$SCRIPT_DIR/utils.sh"

# Check if cipher is in selected profiles
if [[ ! "$COMPOSE_PROFILES" == *"cipher"* ]]; then
    log_info "Cipher not selected, skipping setup"
    exit 0
fi

log_info "Setting up Cipher..."

# Clone Cipher repository if not exists
if [ ! -d "$CIPHER_DIR" ]; then
    log_info "Cloning Cipher repository..."
    git clone https://github.com/campfirein/cipher.git "$CIPHER_DIR"
else
    log_info "Cipher directory already exists, pulling latest..."
    cd "$CIPHER_DIR" && git pull origin main
fi

# Create data directory
mkdir -p "$CIPHER_DIR/data"

# Create cipher.yml configuration for Ollama + Qdrant
log_info "Creating Cipher agent configuration..."

cat > "$CIPHER_DIR/memAgent/cipher.yml" << 'EOF'
# Cipher Agent Configuration for AI LaunchKit
# Uses Ollama for LLM and Qdrant for vector storage

name: "AI LaunchKit Cipher Agent"
description: "Memory-powered AI assistant integrated with local Ollama"

# LLM Configuration - Use Ollama
llm:
  provider: "ollama"
  model: "qwen2.5:7b-instruct-q4_K_M"
  temperature: 0.7
  maxTokens: 4096

# Embedding Configuration - Use Ollama
embedding:
  provider: "ollama"
  model: "nomic-embed-text"

# Memory Configuration
memory:
  enabled: true
  type: "long-term"
  vectorStore:
    type: "qdrant"
    collection: "cipher_knowledge"
  
# Reflection Memory (Self-improvement)
reflection:
  enabled: true
  collection: "cipher_reflection"

# Tools available to the agent
tools:
  - name: "web_search"
    enabled: true
    engine: "duckduckgo"
  - name: "memory_search"
    enabled: true
  - name: "memory_store"
    enabled: true

# System Prompt
systemPrompt: |
  You are a helpful AI assistant with persistent memory capabilities.
  You can remember information from previous conversations and learn over time.
  You are running locally on AI LaunchKit with Ollama as your LLM backend.
  
  Key capabilities:
  - Store and retrieve knowledge from your vector memory
  - Search the web for current information
  - Learn and improve from interactions
  
  Be helpful, accurate, and acknowledge when you're uncertain.
EOF

log_success "Cipher configuration created!"
log_info "Agent config: $CIPHER_DIR/memAgent/cipher.yml"

exit 0
```

### 3.3 Environment Variables

Add to `.env.local.example`:

```bash
############
# Cipher - Memory-Powered AI Agent
# Ports: 3000 (API), 3001 (UI)
############

# Dummy API key for Ollama-only operation
# Cipher requires at least one API key even if not used
# Leave as-is if only using Ollama
CIPHER_OPENAI_API_KEY=sk-dummy-for-ollama-only

# Optional: Real OpenAI key for cloud LLM
# CIPHER_OPENAI_API_KEY=sk-your-real-key

# Optional: Anthropic key
# CIPHER_ANTHROPIC_API_KEY=sk-ant-your-key

# Cipher uses:
# - Qdrant (QDRANT_API_KEY from above)
# - PostgreSQL (POSTGRES_PASSWORD from above)
# - Ollama (no key needed)
```

### 3.4 Wizard Integration

Add to `scripts/04_wizard_local.sh` in `base_services_data` array:

```bash
"cipher" "Cipher (Memory-Powered AI Agent) - Ports 3000, 3001"
```

Add Qdrant dependency check:

```bash
# Auto-enable Qdrant when Cipher is selected
if [[ " ${selected_profiles[@]} " =~ " cipher " ]]; then
    if [[ ! " ${selected_profiles[@]} " =~ " qdrant " ]]; then
        selected_profiles+=("qdrant")
        echo
        log_info "📦 Qdrant will be installed automatically for Cipher"
        sleep 2
    fi
fi
```

### 3.5 Update Script Health Check

Add to `scripts/update_local.sh`:

```bash
# Check Cipher
if [[ "$COMPOSE_PROFILES" == *"cipher"* ]]; then
    if docker ps | grep -q "cipher"; then
        log_success "✅ Cipher is running (Port 3000/3001)"
    else
        FAILED_SERVICES+=("cipher")
    fi
fi
```

### 3.6 Landing Page Dashboard

Add to `templates/landing-page.html`:

```html
<!-- Cipher - Memory AI Agent -->
<div class="service-card" data-profile="cipher">
    <div class="service-icon">🧠</div>
    <h3>Cipher</h3>
    <p>Memory-Powered AI Agent with persistent knowledge</p>
    <div class="service-links">
        <a href="http://{{SERVER_IP}}:3001" target="_blank" class="btn">Web UI</a>
        <a href="http://{{SERVER_IP}}:3000/docs" target="_blank" class="btn btn-secondary">API Docs</a>
    </div>
    <div class="service-ports">Ports: 3000 (API), 3001 (UI)</div>
</div>
```

### 3.7 Documentation

Create `docs/CIPHER_SETUP.md`:

```markdown
# Cipher Setup Guide - AI LaunchKit

## Overview

Cipher is a memory-powered AI agent framework that provides:
- 🧠 Persistent memory across sessions
- 🔍 Knowledge retrieval via vector search
- 🌐 Web search integration
- 💬 Natural conversation with memory context

## Access

- **Web UI**: http://SERVER_IP:3001
- **API**: http://SERVER_IP:3000
- **MCP SSE**: http://SERVER_IP:3000/mcp/sse

## Integration with AI LaunchKit

Cipher is configured to use:
- **Ollama** (port 8021) - Local LLM (qwen2.5:7b-instruct-q4_K_M)
- **Qdrant** (port 8026) - Vector memory storage
- **PostgreSQL** (port 8001) - Chat history database

## Configuration

Agent configuration is in `cipher/memAgent/cipher.yml`:

```yaml
llm:
  provider: "ollama"
  model: "qwen2.5:7b-instruct-q4_K_M"

embedding:
  provider: "ollama"
  model: "nomic-embed-text"

memory:
  vectorStore:
    type: "qdrant"
```

## Dummy API Key

Cipher requires at least one API key (OpenAI or Anthropic) even when using Ollama only. AI LaunchKit provides a dummy key:

```
CIPHER_OPENAI_API_KEY=sk-dummy-for-ollama-only
```

This satisfies Cipher's validation without any cloud API costs.

## Using with MCP (Model Context Protocol)

Cipher exposes an MCP server via SSE transport:

```json
{
  "mcpServers": {
    "cipher": {
      "url": "http://localhost:3000/mcp/sse"
    }
  }
}
```

## Troubleshooting

### Cipher not starting
```bash
docker logs cipher
```

### Memory not persisting
Check Qdrant connection:
```bash
curl http://localhost:8026/collections
```

### Ollama connection issues
Verify Ollama is running:
```bash
curl http://localhost:8021/api/tags
```
```

---

## 4. Integration Architecture Diagram

```mermaid
graph TB
    subgraph AI_LaunchKit[AI LaunchKit Local]
        subgraph Core[Core Services 8000-8019]
            n8n[n8n<br/>Port 8000]
            postgres[(PostgreSQL<br/>Port 8001)]
            redis[(Redis<br/>Port 8002)]
        end
        
        subgraph AI[AI Services 8020-8039]
            ollama[Ollama<br/>Port 8021]
            qdrant[(Qdrant<br/>Port 8026)]
        end
        
        subgraph External[External Port Range]
            cipher_api[Cipher API<br/>Port 3000]
            cipher_ui[Cipher UI<br/>Port 3001]
        end
    end
    
    cipher_api --> ollama
    cipher_api --> qdrant
    cipher_api --> postgres
    cipher_ui --> cipher_api
    
    User((User)) --> cipher_ui
    User --> n8n
    n8n -.->|Webhook| cipher_api
```

---

## 5. File Changes Summary

| File | Action | Description |
|------|--------|-------------|
| `docker-compose.local.yml` | Modify | Add cipher and cipher-init services |
| `.env.local.example` | Modify | Add CIPHER_OPENAI_API_KEY |
| `scripts/04_wizard_local.sh` | Modify | Add cipher to service selection |
| `scripts/04d_setup_cipher.sh` | Create | Clone repo, create cipher.yml |
| `scripts/install_local.sh` | Modify | Call 04d_setup_cipher.sh |
| `scripts/update_local.sh` | Modify | Add cipher health check |
| `templates/landing-page.html` | Modify | Add cipher card to dashboard |
| `docs/CIPHER_SETUP.md` | Create | Setup and usage documentation |
| `README.md` | Modify | Add cipher to service list |

---

## 6. Implementation Order

1. **Create setup script** (`04d_setup_cipher.sh`)
2. **Update docker-compose** (add services)
3. **Update .env.local.example** (add variables)
4. **Update wizard** (add service selection)
5. **Update install script** (call setup)
6. **Update update script** (add health check)
7. **Update landing page** (add dashboard card)
8. **Create documentation** (CIPHER_SETUP.md)
9. **Update README** (add to service list)
10. **Test integration**

---

## 7. Testing Checklist

- [ ] Cipher builds successfully with BUILD_UI=true
- [ ] Cipher API responds on port 3000
- [ ] Cipher UI loads on port 3001
- [ ] Ollama connection works (chat completion)
- [ ] Qdrant connection works (memory storage)
- [ ] PostgreSQL connection works (chat history)
- [ ] Web search functions correctly
- [ ] MCP SSE endpoint accessible
- [ ] Health check passes
- [ ] Service appears in dashboard

---

## 8. Known Considerations

### Port Selection Rationale
Previous integration attempts used ports 8102/8103 which caused issues because:
1. Cipher's Next.js UI has internal proxy that expects port 3001
2. Port remapping required environment variable changes throughout
3. API/UI communication broke with non-standard ports

Using standard ports 3000/3001 avoids these issues entirely.

### Dummy API Key
Cipher's validation requires at least one API key. The dummy key `sk-dummy-for-ollama-only` satisfies this requirement without incurring API costs. Ollama is used for all LLM operations.

### Profile Dependencies
When user selects Cipher, Qdrant is automatically enabled (similar to MySQL/Leantime pattern).

---

## 9. Future Enhancements

- Integration with n8n workflows (webhook triggers)
- Neo4j knowledge graph support (optional)
- Multiple agent configurations
- Custom embedding models
- RAG pipeline with LightRAG

---

*Document Version: 1.0*
*Created: 2026-01-14*
*Author: AI LaunchKit Integration Team*