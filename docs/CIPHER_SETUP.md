# Cipher Setup Guide - AI LaunchKit

## Overview

Cipher is a **memory-powered AI agent framework** that provides persistent knowledge retention across sessions. It integrates seamlessly with AI LaunchKit's existing Ollama and Qdrant services.

### Key Features

- 🧠 **Persistent Memory** - Remember information across conversations (stored in Qdrant)
- 🔍 **Vector Search** - Semantic search through stored knowledge
- 🤖 **Local LLM** - Uses Ollama for private, on-device AI processing
- 🌐 **Web Search** - DuckDuckGo integration for current information
- 📝 **Reflection** - Self-improvement through conversation analysis
- 🔌 **MCP Support** - Model Context Protocol via SSE transport for AI tool integration

---

## Access URLs

Cipher uses two ports:

| Port | Endpoint | URL | Description |
|------|----------|-----|-------------|
| 3000 | **Web UI** | `http://SERVER_IP:3000` | Interactive chat interface |
| 3001 | **REST API** | `http://SERVER_IP:3001/api/` | Programmatic API access |
| 3001 | **API Docs** | `http://SERVER_IP:3001/api/docs` | Swagger/OpenAPI documentation |
| 3001 | **MCP SSE** | `http://SERVER_IP:3001/api/mcp/sse` | Model Context Protocol endpoint |
| 3001 | **Health** | `http://SERVER_IP:3001/api/health` | Service health check |

Replace `SERVER_IP` with your server's actual IP address (e.g., `192.168.178.151`).

---

## Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                         Cipher                                  │
│  ┌─────────────────────┐    ┌─────────────────────┐           │
│  │    REST API         │    │    Web UI           │           │
│  │    Port 3001        │    │    Port 3000        │           │
│  │    /api/*           │    │    /                │           │
│  └──────────┬──────────┘    └──────────┬──────────┘           │
│             │                          │                       │
│             └────────────┬─────────────┘                       │
│                          │                                     │
│                  ┌───────▼───────┐                            │
│                  │  cipher.yml   │                            │
│                  │  (Ollama)     │                            │
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
       LLM +          Vectors        History
     Embeddings
```

---

## ⚠️ Required Ollama Models

Cipher requires two Ollama models to function. These models are **automatically downloaded** during AI LaunchKit installation, but if you're setting up manually or the models are missing, you must install them first.

### Required Models

| Model | Purpose | Size | Download Command |
|-------|---------|------|------------------|
| `nemotron-3-nano:30b` | LLM (Chat/Reasoning) | ~18 GB | `ollama pull nemotron-3-nano:30b` |
| `qwen3-embedding:8b` | Embeddings (Vector Search) | ~4.5 GB | `ollama pull qwen3-embedding:8b` |

### Installing Models Manually

If Cipher fails to start or shows model errors, install the models manually:

```bash
# Connect to the Ollama container
docker exec -it ollama ollama pull nemotron-3-nano:30b
docker exec -it ollama ollama pull qwen3-embedding:8b

# Verify models are installed
docker exec -it ollama ollama list
```

### What Happens Without Models?

If the models are not installed:
- **Cipher will start** but fail on first request
- **Error message**: "model not found" or "failed to load model"
- **Solution**: Install the models using the commands above

---

## Integration with AI LaunchKit

Cipher is pre-configured to use existing AI LaunchKit services:

### Ollama (Local LLM + Embeddings)
- **Internal URL**: `http://ollama:11434` (Docker network)
- **External URL**: `http://SERVER_IP:8021`
- **LLM Model**: `nemotron-3-nano:30b` (NVIDIA's powerful 30B parameter model)
- **Embedding Model**: `qwen3-embedding:8b` (4096 dimensions, state-of-the-art)

### Qdrant (Vector Store)
- **Internal URL**: `http://qdrant:6333` (Docker network)
- **External URL**: `http://SERVER_IP:8026`
- **Collection**: `cipher_knowledge` (auto-created)
- **Vector Size**: 4096 (matches qwen3-embedding:8b)
- **Distance Metric**: Cosine

### PostgreSQL (Chat History)
- **Internal URL**: `postgres://postgres:PASSWORD@postgres:5432/cipher`
- **External URL**: `SERVER_IP:8001`
- **Database**: `cipher` (auto-created by cipher-init)

---

## Configuration

### Agent Configuration (cipher.yml)

The agent behavior is configured in `cipher/memAgent/cipher.yml`:

```yaml
name: "AI LaunchKit Cipher Agent"
description: "Memory-powered AI assistant with persistent knowledge"

llm:
  provider: ollama
  model: nemotron-3-nano:30b
  maxIterations: 50
  baseURL: $OLLAMA_BASE_URL

embedding:
  type: ollama
  model: qwen3-embedding:8b
  baseUrl: $OLLAMA_BASE_URL
  dimensions: 4096

vectorStore:
  type: qdrant
  url: $QDRANT_URL
  collectionName: cipher_knowledge

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

| Variable | Value | Description |
|----------|-------|-------------|
| `OLLAMA_BASE_URL` | `http://ollama:11434` | Ollama API endpoint |
| `QDRANT_URL` | `http://qdrant:6333` | Qdrant vector database |
| `CIPHER_OPENAI_API_KEY` | `sk-dummy-for-ollama-only` | Dummy key (required by Cipher) |
| `POSTGRES_PASSWORD` | (from .env) | PostgreSQL password |

---

## Dummy API Key Explained

Cipher's architecture requires at least one API key to be present (OpenAI or Anthropic), even when using Ollama exclusively. This is a validation requirement in the codebase.

**Solution**: AI LaunchKit provides a dummy key:
```
CIPHER_OPENAI_API_KEY=sk-dummy-for-ollama-only
```

This satisfies Cipher's validation without any cloud API costs. All actual LLM and embedding operations go through Ollama.

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
  provider: openai  # or anthropic
  model: gpt-4o     # or claude-3-sonnet
```

3. Restart Cipher:
```bash
docker compose -p localai -f docker-compose.local.yml restart cipher
```

---

## Using Cipher

### Web Interface

1. Open your browser to `http://SERVER_IP:3000`
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
curl http://SERVER_IP:3001/api/health
```

**Chat via API:**
```bash
curl -X POST http://SERVER_IP:3001/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hello! Remember that my favorite color is blue.",
    "session_id": "user-123"
  }'
```

---

## MCP Integration

Cipher exposes an MCP (Model Context Protocol) server via SSE transport. This allows integration with MCP-compatible clients like Kilo Code, Claude Desktop, or other AI tools.

### MCP Endpoint

```
http://SERVER_IP:3001/api/mcp/sse
```

### Configuration for Kilo Code

Add to your Kilo Code MCP settings (`mcp_settings.json`):

```json
{
  "mcpServers": {
    "cipher": {
      "url": "http://SERVER_IP:3001/api/mcp/sse",
      "transport": "sse",
      "autoApprove": ["ask_cipher"]
    }
  }
}
```

### Configuration for Claude Desktop

Add to your Claude Desktop config:

```json
{
  "mcpServers": {
    "cipher": {
      "url": "http://SERVER_IP:3001/api/mcp/sse"
    }
  }
}
```

### Available MCP Tools

| Tool | Description |
|------|-------------|
| `ask_cipher` | Send a message to Cipher and get a response with memory context |

### Using MCP in Kilo Code

Once configured, you can use Cipher's memory directly in your AI conversations:

```
# Store information
mcp--cipher--ask_cipher: "Remember: The project deadline is January 30th"

# Retrieve information
mcp--cipher--ask_cipher: "What do you know about project deadlines?"
```

---

## Verifying Qdrant Storage

To verify that Cipher is storing data in Qdrant (not in-memory):

### Check Collections
```bash
curl http://SERVER_IP:8026/collections
```

Expected output:
```json
{
  "result": {
    "collections": [
      {"name": "cipher_knowledge"}
    ]
  }
}
```

### Check Collection Details
```bash
curl http://SERVER_IP:8026/collections/cipher_knowledge
```

Expected output:
```json
{
  "result": {
    "status": "green",
    "vectors_count": 6,
    "points_count": 6,
    "config": {
      "params": {
        "vectors": {
          "size": 4096,
          "distance": "Cosine"
        }
      }
    }
  }
}
```

**Key indicators:**
- `vectors_count` > 0 means data is being stored
- `size: 4096` matches qwen3-embedding:8b dimensions
- `distance: Cosine` is the correct metric

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
curl http://SERVER_IP:8026/collections

# Should show cipher_knowledge
```

**Check PostgreSQL:**
```bash
# Connect to cipher database
docker exec -it postgres psql -U postgres -d cipher -c "SELECT COUNT(*) FROM chat_history;"
```

### Ollama Connection Issues

**Verify Ollama is running:**
```bash
curl http://SERVER_IP:8021/api/tags
```

**Check model availability:**
```bash
# Should list nemotron-3-nano:30b and qwen3-embedding:8b
curl http://SERVER_IP:8021/api/tags | jq '.models[].name'
```

**Pull models if missing:**
```bash
docker exec ollama ollama pull nemotron-3-nano:30b
docker exec ollama ollama pull qwen3-embedding:8b
```

### Model Not Found Errors

If you see "model not found" errors in Cipher logs:

1. **Check if models are installed:**
   ```bash
   docker exec ollama ollama list
   ```

2. **Install missing models:**
   ```bash
   docker exec ollama ollama pull nemotron-3-nano:30b
   docker exec ollama ollama pull qwen3-embedding:8b
   ```

3. **Restart Cipher:**
   ```bash
   docker compose -p localai -f docker-compose.local.yml restart cipher
   ```

### Changing Embedding Dimension (Migration)

If you're upgrading from an older version with different embedding dimensions (e.g., 768 → 4096), you must delete the existing Qdrant collection:

```bash
# Delete the old collection (WARNING: This deletes all stored memories!)
curl -X DELETE http://SERVER_IP:8026/collections/cipher_knowledge

# Restart Cipher to recreate the collection with new dimensions
docker compose -p localai -f docker-compose.local.yml restart cipher
```

### MCP Connection Issues

**Test MCP endpoint:**
```bash
curl -N http://SERVER_IP:3001/api/mcp/sse
```

**Check CORS headers:**
```bash
curl -I http://SERVER_IP:3001/api/mcp/sse
```

**Common MCP issues:**
1. **CORS errors** - Cipher is configured to allow all origins
2. **Connection refused** - Check if Cipher container is running
3. **404 errors** - Ensure you're using `/api/mcp/sse` (not `/mcp/sse`)

### Web Search Not Working

**Check DuckDuckGo connectivity:**
```bash
docker exec cipher curl -I https://duckduckgo.com
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
# Pull latest changes
cd ai-launchkit-local
git pull origin main

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
- **MCP Specification**: https://modelcontextprotocol.io/

---

## Quick Reference

| Action | Command |
|--------|---------|
| Start Cipher | `docker compose -p localai -f docker-compose.local.yml up -d cipher` |
| Stop Cipher | `docker compose -p localai -f docker-compose.local.yml stop cipher` |
| View Logs | `docker logs cipher -f` |
| Restart | `docker compose -p localai -f docker-compose.local.yml restart cipher` |
| Rebuild | `docker compose -p localai -f docker-compose.local.yml build --no-cache cipher` |
| Check Health | `curl http://SERVER_IP:3001/api/health` |
| Check Qdrant | `curl http://SERVER_IP:8026/collections/cipher_knowledge` |
| Pull LLM Model | `docker exec ollama ollama pull nemotron-3-nano:30b` |
| Pull Embedding Model | `docker exec ollama ollama pull qwen3-embedding:8b` |
| List Ollama Models | `docker exec ollama ollama list` |

---

*Last Updated: 2026-01-21*
