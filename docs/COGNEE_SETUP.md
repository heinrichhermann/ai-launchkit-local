# Cognee Setup Guide - AI LaunchKit

## Overview

Cognee ist ein **AI Memory & Knowledge Graph Framework**, das automatisch 
Knowledge Graphs und Vector Databases aus deinen Daten erstellt. Es kombiniert
GraphRAG (Graph + Retrieval Augmented Generation) für präzisere AI-Antworten.

### Key Features

- 🧠 **GraphRAG** - Kombiniert Knowledge Graph + Vector Search
- 📊 **ECL Pipeline** - Extract, Cognify, Load
- 🔍 **Semantic Search** - Bedeutungsbasierte Suche
- 📄 **Multi-Format** - Text, PDFs, Bilder, Audio
- 🔌 **MCP Server** - IDE-Integration via Model Context Protocol

---

## Access URLs

| Port | Endpoint | URL | Description |
|------|----------|-----|-------------|
| 8120 | **MCP SSE** | `http://SERVER_IP:8120/sse` | MCP Server (SSE Transport) |
| 8120 | **MCP HTTP** | `http://SERVER_IP:8120/mcp` | MCP Server (HTTP Transport) |
| 8120 | **Health** | `http://SERVER_IP:8120/health` | Health Check |
| 8122 | **Frontend** | `http://SERVER_IP:8122` | Web UI (optional, cognee-ui profile) |
| 8123 | **CORS Proxy** | `http://SERVER_IP:8123` | Nginx CORS Proxy (optional) |

---

## Quick Start

### 1. Enable Cognee Profile

During installation, select "Cognee" in the service wizard, or manually add to `.env`:

```bash
COMPOSE_PROFILES="...,cognee"
```

For the Web UI (optional):
```bash
COMPOSE_PROFILES="...,cognee,cognee-ui"
```

### 2. Start Services

```bash
docker compose -p localai -f docker-compose.local.yml up -d
```

### 3. Verify Installation

```bash
# Check if Cognee MCP is running
curl http://SERVER_IP:8120/health

# Test SSE endpoint
curl -N http://SERVER_IP:8120/sse
```

---

## MCP Client Configuration

### Kilo Code (VS Code)

Add to your MCP settings (`~/.config/Code/User/globalStorage/kilocode.kilo-code/settings/mcp_settings.json`):

```json
{
  "mcpServers": {
    "cognee": {
      "url": "http://SERVER_IP:8120/sse",
      "transport": "sse"
    }
  }
}
```

### Claude Desktop

Add to `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS):

```json
{
  "mcpServers": {
    "cognee": {
      "type": "sse",
      "url": "http://SERVER_IP:8120/sse"
    }
  }
}
```

### Cursor

Add to your Cursor MCP configuration:

```json
{
  "mcpServers": {
    "cognee-sse": {
      "url": "http://SERVER_IP:8120/sse"
    }
  }
}
```

---

## Available MCP Tools

| Tool | Description |
|------|-------------|
| `cognify` | Turns data into structured knowledge graph |
| `search` | Query memory (GRAPH_COMPLETION, RAG_COMPLETION, etc.) |
| `codify` | Analyze code repository, build code graph |
| `delete` | Delete specific data from dataset |
| `list_data` | List all datasets and data items |
| `prune` | Reset cognee (removes all data) |
| `save_interaction` | Log user-agent interactions |

---

## Architecture

Cognee uses existing AI LaunchKit services:

### Ollama (LLM + Embeddings)
- **LLM Model**: `qwen3:8b` (same as Cipher)
- **Embedding Model**: `qwen3-embedding:8b` (4096 dimensions)

### Qdrant (Vector Store)
- **Collection**: Auto-created by Cognee
- **Distance**: Cosine

### PostgreSQL (Relational Data)
- **Database**: `cognee` (auto-created)

### Graph Database (Knowledge Graph)
- **Default**: Kuzu (file-based, no setup needed)
- **Optional**: Neo4j (requires neo4j profile)

---

## Usage Examples

### Via MCP in IDE

```
# Add data to Cognee
Use cognify tool: "Add this document to memory"

# Search memory
Use search tool: "What do you know about X?"

# List stored data
Use list_data tool
```

### Via CLI (inside container)

```bash
# Add data
docker exec -it cognee-mcp cognee-cli add "Your text here"

# Process data into knowledge graph
docker exec -it cognee-mcp cognee-cli cognify

# Search
docker exec -it cognee-mcp cognee-cli search "Your query"

# Reset all data
docker exec -it cognee-mcp cognee-cli delete --all
```

---

## Web UI (Optional)

The Cognee Web UI provides Knowledge Graph visualization. It's marked as "Work in Progress" by the Cognee team.

### Enable Web UI

Add `cognee-ui` to your profiles:

```bash
COMPOSE_PROFILES="...,cognee,cognee-ui"
```

### Access

- **Frontend**: `http://SERVER_IP:8122`
- **CORS Proxy**: `http://SERVER_IP:8123` (for API access)

### Note on CORS

The Cognee MCP server has CORS hardcoded to `localhost:3000`. The included Nginx proxy (`cognee-nginx`) adds proper CORS headers for remote access.

---

## Troubleshooting

### Cognee Not Starting

```bash
# Check logs
docker logs cognee-mcp

# Common issues:
# - Database not ready: Wait for PostgreSQL to initialize
# - Model not found: Pull required Ollama models
```

### Model Not Found

```bash
# Pull required models
docker exec ollama ollama pull qwen3-embedding:8b
docker exec ollama ollama pull qwen3:8b
```

### MCP Connection Issues

```bash
# Test SSE endpoint
curl -N http://SERVER_IP:8120/sse

# Check if port is accessible
nc -zv SERVER_IP 8120
```

### Database Migration Errors

```bash
# Check migration logs
docker logs cognee-mcp | grep -i migration

# If needed, reset database
docker exec -it postgres psql -U postgres -c "DROP DATABASE cognee;"
docker compose -p localai -f docker-compose.local.yml restart cognee-init cognee-mcp
```

---

## Service Dependencies

| Service | Profile | Required |
|---------|---------|----------|
| PostgreSQL | (always on) | ✅ Yes |
| Qdrant | `qdrant` | ✅ Yes (auto-enabled) |
| Ollama | `cpu`/`gpu-*` | ✅ Yes |
| Neo4j | `neo4j` | ❌ Optional |

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `COGNEE_MCP_PORT` | 8120 | MCP Server port |
| `COGNEE_FRONTEND_PORT` | 8122 | Web UI port |
| `COGNEE_NGINX_PORT` | 8123 | CORS Proxy port |
| `COGNEE_GRAPH_PROVIDER` | kuzu | Graph DB (kuzu or neo4j) |
| `COGNEE_GRAPH_URL` | - | Neo4j URL (if using neo4j) |

---

## Quick Reference

| Action | Command |
|--------|---------|
| Start | `docker compose -p localai -f docker-compose.local.yml up -d cognee-mcp` |
| Stop | `docker compose -p localai -f docker-compose.local.yml stop cognee-mcp` |
| Logs | `docker logs cognee-mcp -f` |
| Restart | `docker compose -p localai -f docker-compose.local.yml restart cognee-mcp` |
| Health | `curl http://SERVER_IP:8120/health` |

---

## Comparison: Cognee vs. Cipher

| Feature | Cognee | Cipher |
|---------|--------|--------|
| **Focus** | Knowledge Graph + RAG | Agent Memory |
| **Graph DB** | Kuzu/Neo4j | - |
| **Vector DB** | Qdrant | Qdrant |
| **MCP Tools** | cognify, search, codify, etc. | ask_cipher |
| **Code Analysis** | ✅ codify | ❌ |
| **Multi-Format** | ✅ PDFs, Images, Audio | ❌ Text only |
| **Use Case** | Document Intelligence | Conversation Memory |

**Recommendation**: Both services can run in parallel and complement each other:
- **Cipher** for conversation memory
- **Cognee** for document intelligence and code analysis

---

## Resources

- [Cognee GitHub](https://github.com/topoteretes/cognee)
- [Cognee Documentation](https://docs.cognee.ai/)
- [cognee-mcp Repository](https://github.com/topoteretes/cognee/tree/main/cognee-mcp)

---

*Last updated: 2026-01-22*
