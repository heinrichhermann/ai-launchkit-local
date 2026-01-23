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

## Architecture

Cognee in AI LaunchKit besteht aus **drei Services**:

```
┌─────────────────────────────────────────────────────────────────┐
│                        AI LaunchKit                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────┐    ┌─────────────────┐    ┌──────────────┐ │
│  │  cognee-api     │    │  cognee-mcp     │    │ cognee-      │ │
│  │  (Port 8120)    │◄───│  (Port 8121)    │    │ frontend     │ │
│  │                 │    │                 │    │ (Port 8122)  │ │
│  │  FastAPI REST   │    │  MCP Server     │    │              │ │
│  │  Server         │    │  (API Mode)     │    │  Web UI      │ │
│  └────────┬────────┘    └─────────────────┘    └──────┬───────┘ │
│           │                                           │         │
│           │                                           │         │
│           ▼                                           ▼         │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                    cognee-api:8120                          ││
│  │              (Frontend connects here)                       ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐ │
│  │ Ollama   │  │PostgreSQL│  │ LanceDB  │  │ Neo4j (Graph DB) │ │
│  │ (LLM)    │  │ (Data)   │  │ (Vectors)│  │ (Knowledge Graph)│ │
│  └──────────┘  └──────────┘  └──────────┘  └──────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

| Service | Port | Image | Description |
|---------|------|-------|-------------|
| **cognee-api** | 8120 | `cognee/cognee:main` | FastAPI REST Server - für Frontend & API |
| **cognee-mcp** | 8121 | `cognee/cognee-mcp:main` | MCP Server - für IDE Integration |
| **cognee-frontend** | 8122 | Custom Build | Web UI - Knowledge Graph Visualization |

---

## Access URLs

| Port | Endpoint | URL | Description |
|------|----------|-----|-------------|
| 8120 | **REST API** | `http://SERVER_IP:8120` | FastAPI Server (Swagger: /docs) |
| 8120 | **Health** | `http://SERVER_IP:8120/health` | API Health Check |
| 8121 | **MCP SSE** | `http://SERVER_IP:8121/sse` | MCP Server (SSE Transport) |
| 8121 | **MCP HTTP** | `http://SERVER_IP:8121/mcp` | MCP Server (HTTP Transport) |
| 8122 | **Frontend** | `http://SERVER_IP:8122` | Web UI (optional, cognee-ui profile) |

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
# Check if Cognee API is running
curl http://SERVER_IP:8120/health

# Check if MCP Server is running
curl http://SERVER_IP:8121/health

# Test SSE endpoint
curl -N http://SERVER_IP:8121/sse
```

---

## MCP Client Configuration

### Kilo Code (VS Code)

Add to your MCP settings (`~/.config/Code/User/globalStorage/kilocode.kilo-code/settings/mcp_settings.json`):

```json
{
  "mcpServers": {
    "cognee": {
      "url": "http://SERVER_IP:8121/sse",
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
      "url": "http://SERVER_IP:8121/sse"
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
      "url": "http://SERVER_IP:8121/sse"
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

## Backend Services

Cognee uses existing AI LaunchKit services:

### Ollama (LLM + Embeddings)
- **LLM Model**: `qwen3:8b` (same as Cipher)
- **Embedding Model**: `qwen3-embedding:8b` (4096 dimensions)

### LanceDB (Vector Store)
- **Embedded** - No extra service needed
- **Storage**: `/app/.cognee_system/databases`

### PostgreSQL (Relational Data)
- **Database**: `cognee` (auto-created)

### Neo4j (Knowledge Graph) - Default
- **Port**: 8028 (HTTP Browser), 7687 (Bolt)
- **Browser**: `http://SERVER_IP:8028`
- **Bolt URL**: `bolt://neo4j:7687`
- **Requires**: `neo4j` profile enabled
- **APOC Plugin**: Automatically installed (required for Cognee)

Neo4j is the **default** graph database for Cognee, enabling:
- 🔍 **Visual Knowledge Graph Exploration** in Neo4j Browser
- 📊 **Cypher Queries** for advanced graph analysis
- 🔗 **Entity Relationship Visualization**

> **Note**: Cognee requires the APOC plugin for dynamic label creation. This is automatically configured in the docker-compose.local.yml.

### Kuzu (Alternative Graph Database)
- **File-based** - No extra service needed
- **Storage**: `/app/.cognee_system/databases`
- Set `COGNEE_GRAPH_PROVIDER=kuzu` to use instead of Neo4j

---

## Neo4j Knowledge Graph Visualization

### Prerequisites

1. **Enable neo4j profile** in your `.env`:
   ```bash
   COMPOSE_PROFILES="...,neo4j,cognee"
   ```

2. **Set Neo4j password** in `.env`:
   ```bash
   NEO4J_AUTH_PASSWORD=your_secure_password
   ```

### Start Neo4j + Cognee

```bash
docker compose -p localai -f docker-compose.local.yml up -d neo4j cognee-api cognee-mcp
```

### Access Neo4j Browser

1. Open `http://SERVER_IP:8028` in your browser
2. Connect with:
   - **Connect URL**: `bolt://localhost:7687`
   - **Username**: `neo4j`
   - **Password**: Your `NEO4J_AUTH_PASSWORD`

### Explore Knowledge Graph

After adding data to Cognee and running `cognify`, you can explore the Knowledge Graph:

```cypher
// Show all nodes
MATCH (n) RETURN n LIMIT 100

// Show all relationships
MATCH (n)-[r]->(m) RETURN n, r, m LIMIT 100

// Find specific entities
MATCH (n) WHERE n.name CONTAINS 'AI' RETURN n

// Show entity connections
MATCH (n)-[r]->(m)
WHERE n.name CONTAINS 'Cognee'
RETURN n, r, m
```

### Verify Neo4j Connection

```bash
# Check if Cognee is using Neo4j
docker logs cognee-api | grep -i neo4j

# Should show:
# GRAPH_DATABASE_PROVIDER=neo4j
# GRAPH_DATABASE_URL=bolt://neo4j:7687
```

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

### Via REST API

```bash
# Add data
curl -X POST http://SERVER_IP:8120/api/v1/add \
  -H "Content-Type: application/json" \
  -d '{"data": "Your text here"}'

# Cognify (process into knowledge graph)
curl -X POST http://SERVER_IP:8120/api/v1/cognify

# Search
curl -X POST http://SERVER_IP:8120/api/v1/search \
  -H "Content-Type: application/json" \
  -d '{"query": "Your query"}'
```

### Via CLI (inside container)

```bash
# Add data
docker exec -it cognee-api python -c "
import cognee
import asyncio
asyncio.run(cognee.add('Your text here'))
"

# Process data into knowledge graph
docker exec -it cognee-api python -c "
import cognee
import asyncio
asyncio.run(cognee.cognify())
"

# Search
docker exec -it cognee-api python -c "
import cognee
import asyncio
results = asyncio.run(cognee.search('Your query'))
print(results)
"
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

### Note

The Frontend connects directly to `cognee-api` (Port 8120) for all API calls. Make sure the API server is running before starting the frontend.

---

## Troubleshooting

### cognify_status Error: "unable to open database file"

This is a **known limitation** in the cognee-mcp server when running in **API Mode**. The `cognify_status` tool tries to access a local SQLite database that doesn't exist in API mode.

**Workaround**: Check the cognee-api logs instead:

```bash
# Check cognify progress in API logs
docker logs cognee-api 2>&1 | tail -50

# Look for:
# - "Cognify process starting" - cognify started
# - "Cognify process finished" - cognify completed
# - Error messages if something failed
```

**Alternative**: Use the `search` tool to verify data was processed:
```
# If search returns results, cognify completed successfully
search(search_query="your topic", search_type="CHUNKS")
```

### Cognee Not Starting

```bash
# Check API logs
docker logs cognee-api

# Check MCP logs
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
# Test SSE endpoint (MCP Server on port 8121!)
curl -N http://SERVER_IP:8121/sse

# Check if port is accessible
nc -zv SERVER_IP 8121
```

### Frontend CORS Errors

The `cognee-api` server reads `CORS_ALLOWED_ORIGINS` from environment. If you see CORS errors:

```bash
# Check the CORS configuration
docker exec cognee-api env | grep CORS

# Should show:
# CORS_ALLOWED_ORIGINS=http://SERVER_IP:8122,http://localhost:8122,http://localhost:3000
```

### Database Migration Errors

```bash
# Check migration logs
docker logs cognee-api | grep -i migration

# If needed, reset database
docker exec -it postgres psql -U postgres -c "DROP DATABASE cognee;"
docker compose -p localai -f docker-compose.local.yml restart cognee-init cognee-api
```

---

## Service Dependencies

| Service | Profile | Required | Description |
|---------|---------|----------|-------------|
| PostgreSQL | (always on) | ✅ Yes | Relational data storage |
| Ollama | `cpu`/`gpu-*` | ✅ Yes | LLM + Embeddings |
| Neo4j | `neo4j` | ✅ Recommended | Knowledge Graph visualization |

**Notes**:
- LanceDB is embedded in Cognee - no separate service needed!
- Neo4j is the **default** graph database for Knowledge Graph visualization
- If Neo4j is not available, Cognee falls back to Kuzu (file-based)

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `COGNEE_API_PORT` | 8120 | API Server port |
| `COGNEE_MCP_PORT` | 8121 | MCP Server port |
| `COGNEE_FRONTEND_PORT` | 8122 | Web UI port |
| `COGNEE_GRAPH_PROVIDER` | neo4j | Graph DB (neo4j or kuzu) |
| `COGNEE_GRAPH_URL` | bolt://neo4j:7687 | Neo4j Bolt URL |
| `NEO4J_AUTH_USERNAME` | neo4j | Neo4j username |
| `NEO4J_AUTH_PASSWORD` | - | Neo4j password (required!) |

---

## Quick Reference

| Action | Command |
|--------|---------|
| Start API | `docker compose -p localai -f docker-compose.local.yml up -d cognee-api` |
| Start MCP | `docker compose -p localai -f docker-compose.local.yml up -d cognee-mcp` |
| Stop | `docker compose -p localai -f docker-compose.local.yml stop cognee-api cognee-mcp` |
| Logs API | `docker logs cognee-api -f` |
| Logs MCP | `docker logs cognee-mcp -f` |
| Restart | `docker compose -p localai -f docker-compose.local.yml restart cognee-api cognee-mcp` |
| Health API | `curl http://SERVER_IP:8120/health` |
| Health MCP | `curl http://SERVER_IP:8121/health` |

---

## Comparison: Cognee vs. Cipher

| Feature | Cognee | Cipher |
|---------|--------|--------|
| **Focus** | Knowledge Graph + RAG | Agent Memory |
| **Graph DB** | Neo4j (default) / Kuzu | - |
| **Vector DB** | LanceDB (embedded) | Qdrant |
| **Graph Visualization** | ✅ Neo4j Browser | ❌ |
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

*Last updated: 2026-01-23*
