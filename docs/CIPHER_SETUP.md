# Cipher Setup Guide - AI LaunchKit

## Overview

Cipher is a **memory-powered AI agent framework** that provides persistent knowledge retention across sessions. It integrates seamlessly with AI LaunchKit's existing Ollama and Qdrant services.

### Key Features

- 🧠 **Persistent Memory** - Remember information across conversations
- 🔍 **Vector Search** - Semantic search through stored knowledge (via Qdrant)
- 🤖 **Local LLM** - Uses Ollama for private, on-device AI processing
- 🌐 **Web Search** - DuckDuckGo integration for current information
- 📝 **Reflection** - Self-improvement through conversation analysis
- 🔌 **MCP Support** - Model Context Protocol via SSE transport

---

## Access URLs

| Service | URL | Description |
|---------|-----|-------------|
| **Web UI** | `http://SERVER_IP:3001` | Interactive chat interface |
| **REST API** | `http://SERVER_IP:3000` | Programmatic API access |
| **API Docs** | `http://SERVER_IP:3000/docs` | Swagger/OpenAPI documentation |
| **MCP SSE** | `http://SERVER_IP:3000/mcp/sse` | Model Context Protocol endpoint |
| **Health** | `http://SERVER_IP:3000/health` | Service health check |

Replace `SERVER_IP` with your server's actual IP address (e.g., `192.168.1.100`).

---

## Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                         Cipher                                  │
│  ┌─────────────────────┐    ┌─────────────────────┐           │
│  │    REST API         │    │    Web UI           │           │
│  │    Port 3000        │    │    Port 3001        │           │
│  └──────────┬──────────┘    └──────────┬──────────┘           │
│             │                          │                       │
│             └────────────┬─────────────┘                       │
│                          │                                     │
│                  ┌───────▼───────┐                            │
│                  │  cipher.yml   │                            │
│                  └───────┬───────┘                            │
└──────────────────────────┼─────────────────────────────────────┘
                           │
           ┌───────────────┼───────────────┐
           │               │               │
           ▼               ▼               ▼
    ┌──────────┐    ┌──────────┐    ┌──────────┐
    │  Ollama  │    │  Qdrant  │    │ PostgreSQL│
    │  :8021   │    │  :8026   │    │   :8001   │
    └──────────┘    └──────────┘    └──────────┘
       LLM           Vectors        History
```

---

## Integration with AI LaunchKit

Cipher is pre-configured to use existing AI LaunchKit services:

### Ollama (Local LLM)
- **URL**: `http://ollama:11434` (internal Docker network)
- **Model**: `qwen2.5:7b-instruct-q4_K_M` (default)
- **Embedding**: `nomic-embed-text`
- **Port**: 8021 (external access)

### Qdrant (Vector Store)
- **URL**: `http://qdrant:6333` (internal Docker network)
- **Collection**: `cipher_knowledge` (auto-created)
- **Reflection**: `cipher_reflection` (auto-created)
- **Port**: 8026 (external access)

### PostgreSQL (Chat History)
- **URL**: `postgres://postgres:PASSWORD@postgres:5432/cipher`
- **Database**: `cipher` (auto-created by cipher-init)
- **Port**: 8001 (external access)

---

## Configuration

### Agent Configuration

The agent behavior is configured in `cipher/memAgent/cipher.yml`:

```yaml
name: "AI LaunchKit Cipher Agent"
description: "Memory-powered AI assistant"

llm:
  provider: "ollama"
  model: "qwen2.5:7b-instruct-q4_K_M"
  temperature: 0.7
  maxTokens: 4096

embedding:
  provider: "ollama"
  model: "nomic-embed-text"

memory:
  enabled: true
  vectorStore:
    type: "qdrant"
    collection: "cipher_knowledge"

tools:
  - name: "web_search"
    enabled: true
  - name: "memory_search"
    enabled: true
  - name: "memory_store"
    enabled: true
```

### Environment Variables

Cipher uses these environment variables (from `.env`):

| Variable | Default | Description |
|----------|---------|-------------|
| `CIPHER_OPENAI_API_KEY` | `sk-dummy-for-ollama-only` | Dummy key for Ollama-only |
| `CIPHER_ANTHROPIC_API_KEY` | (empty) | Optional cloud LLM |
| `QDRANT_API_KEY` | (from .env) | Qdrant authentication |
| `POSTGRES_PASSWORD` | (from .env) | PostgreSQL password |

---

## Dummy API Key Explained

Cipher's architecture requires at least one API key to be present (OpenAI or Anthropic), even when using Ollama exclusively. This is a validation requirement in the codebase.

**Solution**: AI LaunchKit provides a dummy key:
```
CIPHER_OPENAI_API_KEY=sk-dummy-for-ollama-only
```

This satisfies Cipher's validation without any cloud API costs. All actual LLM operations go through Ollama.

### Using Real Cloud APIs (Optional)

If you want to use cloud LLMs instead of Ollama:

1. Edit `.env`:
```bash
# Use real OpenAI key
CIPHER_OPENAI_API_KEY=sk-your-real-openai-key

# Or use Anthropic
CIPHER_ANTHROPIC_API_KEY=sk-ant-your-key
```

2. Update `cipher/memAgent/cipher.yml`:
```yaml
llm:
  provider: "openai"  # or "anthropic"
  model: "gpt-4o"     # or "claude-3-sonnet"
```

3. Restart Cipher:
```bash
docker compose -p localai -f docker-compose.local.yml restart cipher
```

---

## Using Cipher

### Web Interface

1. Open your browser to `http://SERVER_IP:3001`
2. Start a conversation - Cipher remembers context!
3. Ask about previous conversations - it recalls stored memories

### Example Conversations

**Storing Information:**
```
You: My name is Alex and I work at TechCorp as a software engineer.
Cipher: Nice to meet you, Alex! I'll remember that you work at TechCorp 
        as a software engineer. How can I help you today?
```

**Recalling Information (in a new session):**
```
You: What do you remember about me?
Cipher: I remember that your name is Alex and you work at TechCorp 
        as a software engineer.
```

**Web Search:**
```
You: What's the latest news about AI?
Cipher: Let me search for recent AI news... [performs DuckDuckGo search]
        Here's what I found: [summarizes results]
```

### REST API Usage

**Health Check:**
```bash
curl http://localhost:3000/health
```

**Chat Completion:**
```bash
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hello! Remember that my favorite color is blue.",
    "session_id": "user-123"
  }'
```

**Search Memories:**
```bash
curl http://localhost:3000/api/memories/search?query=favorite+color
```

---

## MCP Integration

Cipher exposes an MCP (Model Context Protocol) server via SSE transport. This allows integration with MCP-compatible clients.

### Configuration for MCP Clients

Add to your MCP client configuration:

```json
{
  "mcpServers": {
    "cipher": {
      "url": "http://localhost:3000/mcp/sse"
    }
  }
}
```

### Available MCP Tools

- `memory_search` - Search stored knowledge
- `memory_store` - Store new information
- `web_search` - Search the web via DuckDuckGo

---

## Troubleshooting

### Cipher Not Starting

**Check logs:**
```bash
docker logs cipher
```

**Common issues:**
1. **Database not ready** - Wait for cipher-init to complete
2. **Qdrant not running** - Ensure Qdrant profile is enabled
3. **Port conflict** - Check if 3000/3001 are available

### Memory Not Persisting

**Check Qdrant connection:**
```bash
# View Qdrant collections
curl http://localhost:8026/collections

# Should show cipher_knowledge and cipher_reflection
```

**Check PostgreSQL:**
```bash
# Connect to cipher database
docker exec -it postgres psql -U postgres -d cipher -c "SELECT COUNT(*) FROM chat_history;"
```

### Ollama Connection Issues

**Verify Ollama is running:**
```bash
curl http://localhost:8021/api/tags
```

**Check model availability:**
```bash
# Should list qwen2.5:7b-instruct-q4_K_M
curl http://localhost:8021/api/tags | grep qwen
```

**Pull model if missing:**
```bash
docker exec ollama ollama pull qwen2.5:7b-instruct-q4_K_M
docker exec ollama ollama pull nomic-embed-text
```

### Web Search Not Working

**Check DuckDuckGo connectivity:**
```bash
curl -I https://duckduckgo.com
```

Web search requires internet access from the Docker container.

---

## Service Dependencies

Cipher requires these services to be running:

| Service | Profile | Required |
|---------|---------|----------|
| PostgreSQL | (always on) | ✅ Yes |
| Qdrant | `qdrant` | ✅ Yes |
| Ollama | `cpu`/`gpu-nvidia`/`gpu-amd` | ✅ Yes |

The wizard automatically enables Qdrant when Cipher is selected.

---

## Updating Cipher

When updating AI LaunchKit:

```bash
# Pull latest Cipher code
cd cipher && git pull origin main && cd ..

# Rebuild Cipher container
docker compose -p localai -f docker-compose.local.yml build --no-cache cipher

# Restart
docker compose -p localai -f docker-compose.local.yml up -d cipher
```

---

## Resources

- **Cipher Repository**: https://github.com/campfirein/cipher
- **AI LaunchKit**: https://github.com/heinrichhermann/ai-launchkit-local
- **Qdrant Docs**: https://qdrant.tech/documentation/
- **Ollama Docs**: https://github.com/ollama/ollama

---

## Quick Reference

| Action | Command |
|--------|---------|
| Start Cipher | `docker compose -p localai -f docker-compose.local.yml up -d cipher` |
| Stop Cipher | `docker compose -p localai -f docker-compose.local.yml stop cipher` |
| View Logs | `docker logs cipher -f` |
| Restart | `docker compose -p localai -f docker-compose.local.yml restart cipher` |
| Rebuild | `docker compose -p localai -f docker-compose.local.yml build --no-cache cipher` |

---

*Last Updated: 2026-01-14*