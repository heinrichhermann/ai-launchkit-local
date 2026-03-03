# 🚀 AI LaunchKit Local v1.1.0 Release Notes

**Release Date:** 2026-02-05  
**Commits since v1.0.0:** 103  
**Changes:** +4,904 / -3,473 lines across 32 files

---

## 🌟 Highlights

Diese Version bringt **massive Verbesserungen** für AI Agent Memory, Web Scraping, Multi-GPU Performance und Developer Experience.

---

## ✨ Neue Features

### 🧠 Cognee - AI Memory & Knowledge Graph (NEU!)

Vollständige Integration von [Cognee](https://github.com/topoteretes/cognee) als AI Agent Memory System:

- **Knowledge Graph + Vector DB**: Automatische Wissensgraph-Erstellung aus Daten
- **Neo4j Integration**: Graph-Visualisierung mit APOC Plugin
- **MCP Server (Direct Mode)**: Native Integration in VS Code, Cursor, Claude Desktop
- **Web Frontend**: Daten-Upload und Graph-Exploration (Port 8122)
- **Qdrant Vector Store**: Semantische Suche über alle Daten
- **Ollama Integration**: Lokale LLMs (qwen3:8b) + Embeddings (qwen3-embedding:8b)

**Neue Services:**
- `cognee-api` (Port 8120) - FastAPI Backend
- `cognee-mcp` (Port 8121) - MCP Server für IDE-Integration
- `cognee-frontend` (Port 8122) - Web UI
- `cognee-nginx` (Port 8123) - CORS Proxy

**Dokumentation:** [docs/COGNEE_SETUP.md](docs/COGNEE_SETUP.md)

---

### 🕷️ Crawl4AI + Open WebUI Integration (NEU!)

Automatische Web-Scraping-Fähigkeiten für Open WebUI:

- **Tool Server Auto-Configuration**: Crawl4AI wird automatisch als Tool Server registriert
- **OpenAPI Integration**: Nutzt `/openapi.json` für Tool-Discovery
- **Direct Connections**: `ENABLE_DIRECT_CONNECTIONS=true` aktiviert

**Dokumentation:** [docs/CRAWL4AI_OPENWEBUI_SETUP.md](docs/CRAWL4AI_OPENWEBUI_SETUP.md)

---

### 🔍 SearXNG + Open WebUI Web Search (NEU!)

Privacy-fokussierte Web-Suche direkt in Open WebUI:

- **Docker-interne Kommunikation**: Nutzt Docker-Netzwerk statt externe IPs
- **Auto-Enable im Wizard**: SearXNG wird automatisch aktiviert wenn Open WebUI gewählt wird
- **Rate-Limiting Fix**: Google/Bing deaktiviert um Blockierungen zu vermeiden

**Dokumentation:** [docs/SEARXNG_OPENWEBUI_SETUP.md](docs/SEARXNG_OPENWEBUI_SETUP.md)

---

### 🎨 Penpot Design Platform (NEU!)

Open-Source Figma-Alternative mit MCP-Integration:

- **Self-hosted Design Tool**: Vollständige Penpot-Installation
- **PostgreSQL Backend**: Dedizierte Datenbank
- **MCP Integration Guide**: Für AI-gestützte Design-Workflows

**Dokumentation:** 
- [docs/PENPOT_SETUP.md](docs/PENPOT_SETUP.md)
- [docs/PENPOT_MCP_INTEGRATION.md](docs/PENPOT_MCP_INTEGRATION.md)

---

## ⚡ Performance-Optimierungen

### 🎮 Ollama Multi-GPU Optimierungen

Optimiert für **2x RTX 3090** (48GB VRAM total):

| Setting | v1.0.0 | v1.1.0 | Verbesserung |
|---------|--------|--------|--------------|
| `OLLAMA_NUM_PARALLEL` | 1 | 4 | **4x mehr parallele Requests** |
| `OLLAMA_SCHED_SPREAD` | false | true | **Modelle über beide GPUs verteilt** |
| `OLLAMA_MULTIUSER_CACHE` | false | true | **Besseres Multi-User Caching** |
| `OLLAMA_KEEP_ALIVE` | 5m | 10m | **Weniger Model-Reloads** |
| `OLLAMA_GPU_OVERHEAD` | 0 | 512MB | **Stabilere GPU-Nutzung** |

**Bestehende Optimierungen (unverändert):**
- `OLLAMA_CONTEXT_LENGTH=131072` (128K Context)
- `OLLAMA_FLASH_ATTENTION=1`
- `OLLAMA_KV_CACHE_TYPE=q8_0`
- `OLLAMA_MAX_LOADED_MODELS=2`

---

## 🔧 Verbesserungen

### 📦 Update-System komplett überarbeitet

Das `update_local.sh` Script wurde grundlegend verbessert:

- **Floating-Tag Images**: Korrekte Updates für `latest`, `main`, `nightly` Tags
- **n8n Custom Build**: Force-Pull des Base Images vor Rebuild
- **Penpot Cache Clearing**: Automatisches Löschen des Image-Caches
- **Open Notebook**: Stabile Version-Tags (`v1-latest-single`)
- **Scriberr**: Robusteres Init-Script für SQLite readonly Fix
- **Health Checks**: Automatische Validierung nach Updates

### 🎙️ Open Notebook Verbesserungen

- **Stabile Version**: Umstellung auf `1.2.4-single` Tag
- **API URL Fix**: Korrekte externe IP-Konfiguration
- **YouTube Integration**: Neuer Workflow für YouTube → Podcast

**Dokumentation:**
- [docs/OPEN_NOTEBOOK_SETUP.md](docs/OPEN_NOTEBOOK_SETUP.md)
- [docs/SCRIBERR_N8N_YOUTUBE.md](docs/SCRIBERR_N8N_YOUTUBE.md)

### 🗄️ PostgreSQL Tuning

Neue Dokumentation für Datenbank-Optimierung:
- [docs/POSTGRESQL_TUNING.md](docs/POSTGRESQL_TUNING.md)

---

## 📚 Neue Dokumentation

| Datei | Beschreibung |
|-------|--------------|
| `docs/COGNEE_SETUP.md` | Cognee Installation & Konfiguration |
| `docs/CRAWL4AI_OPENWEBUI_SETUP.md` | Web Scraping in Open WebUI |
| `docs/SEARXNG_OPENWEBUI_SETUP.md` | Web Search Integration |
| `docs/PENPOT_SETUP.md` | Penpot Installation |
| `docs/PENPOT_MCP_INTEGRATION.md` | Penpot + AI Workflows |
| `docs/POSTGRESQL_TUNING.md` | Datenbank-Optimierung |
| `docs/SCRIBERR_N8N_YOUTUBE.md` | YouTube → Podcast Workflow |

---

## 🐛 Bug Fixes

### Kritische Fixes

- **Cognee CORS**: Python-basierter Patch für Frontend-Zugriff
- **Neo4j APOC**: Plugin für Knowledge Graph Queries
- **Scriberr GPU**: SQLite readonly Database Fix
- **n8n Updates**: Force-Pull für Base Image Updates
- **Penpot PostgreSQL**: Sonderzeichen in Passwörtern

### Weitere Fixes

- SearXNG Rate-Limiting (Google/Bing deaktiviert)
- Open Notebook API URL für externe IPs
- Perplexica Migration zu Docker Hub Image
- Formbricks/Langfuse dynamische SERVER_IP

---

## 📊 Statistiken

| Metrik | Wert |
|--------|------|
| Commits seit v1.0.0 | 103 |
| Neue Dokumentationen | 7 |
| Neue Services | 4 (Cognee Stack) |
| Geänderte Dateien | 32 |
| Hinzugefügte Zeilen | +4,904 |
| Entfernte Zeilen | -3,473 |

---

## 🔄 Upgrade von v1.0.0

```bash
# 1. Repository aktualisieren
cd ai-launchkit-local
git pull origin main

# 2. Neue .env Variablen hinzufügen (falls Cognee gewünscht)
# Siehe .env.local.example für COGNEE_* Variablen

# 3. Services aktualisieren
sudo bash ./scripts/update_local.sh

# 4. Optional: Cognee aktivieren
sudo bash ./scripts/04e_setup_cognee.sh
```

---

## 🙏 Credits

- **Cognee**: [topoteretes/cognee](https://github.com/topoteretes/cognee)
- **Crawl4AI**: [unclecode/crawl4ai](https://github.com/unclecode/crawl4ai)
- **Penpot**: [penpot/penpot](https://github.com/penpot/penpot)
- **AI LaunchKit**: [freddy-schuetz/ai-launchkit](https://github.com/freddy-schuetz/ai-launchkit)

---

## 📋 Vollständiger Changelog

<details>
<summary>Alle Commits anzeigen</summary>

```
8d7d85f fix(searxng): disable Google/Bing to prevent rate limiting
c40b522 feat(ollama): add multi-GPU and parallelization optimizations
b4b202b feat(open-webui): Add Crawl4AI Tool Server auto-configuration
edb310b fix: Comprehensive update script improvements for floating-tag images
ee9699a fix: Add Penpot image cache clearing to update script
efc7f3e fix: Force fresh n8n base image pull during update
0815706 chore: Remove remaining references from documentation and plans
5e4e29a Remove unused components from AI LaunchKit
04cb67c feat: Add Cognee to landing page dashboard (Port 8122)
24aa02b fix(cognee-frontend): Add dummy cloud API key and local environment flag
9a2d6f7 fix(cognee): Improve CORS patch in mcp.Dockerfile using Python
4c48b1d fix(cognee-mcp): Add CORS patch Dockerfile for frontend access
51a2b39 fix: add ENABLE_BACKEND_ACCESS_CONTROL=false to cognee-mcp for Direct Mode
ffd2891 feat(cognee): Switch cognee-mcp from API Mode to Direct Mode
34533a5 fix(cognee): add volumes and DB config to cognee-mcp for cognify_status
ae3aca8 docs(cognee): Document cognify_status limitation in API mode
4528f0c fix(neo4j): Add APOC plugin for Cognee Knowledge Graph support
b972d50 feat(cognee): Enable Neo4j as default graph database for Knowledge Graph visualization
c653fb1 fix(cognee-frontend): add NEXT_PUBLIC_MCP_API_URL for MCP health check
693aeea fix(cognee): disable healthchecks for cognee containers
aad94f5 fix(cognee): disable cloud sync for local-only setup
6b751ae fix(cognee): add HUGGINGFACE_TOKENIZER and disable access control
32e2b10 fix(cognee): Use official cognee/cognee:main image for API server
6fe26db fix(cognee): Fix CORS patch - use direct sed on /app/src/server.py
a1f0bd3 fix(cognee): Improve CORS patch in Dockerfile using Python regex
f25993e fix(cognee): Frontend environment variable injection for Next.js
fad5570 fix(cognee): CORS patch with env var for credentials support
fc3063b fix(cognee): CORS patch via Dockerfile build-time patching
8bdf97c fix(cognee): Use external SERVER_IP for frontend API URL
b68ef2b fix(cognee): Add .env file to fix Vector DB Provider issue
ae103b2 Add custom cognee entrypoint with setup.py fallback (fixes Issue #2007)
1a07434 Fix: HUGGINGFACE_TOKENIZER für Cognee Embeddings hinzugefügt
6983aa3 feat: Add Cognee firewall rules and dashboard entries
a3fde4f fix: Change to project root directory in install_local.sh
02a142a feat: Add Cognee AI Memory & Knowledge Graph integration
7c2b062 PUID PGID fix scriberrr
695852f feat(wizard): auto-enable SearXNG when Open WebUI is selected
fe4a0eb fix(searxng): use Docker internal network for Open WebUI integration
b888d1e fix: Use host.docker.internal:8089 for SEARXNG_QUERY_URL
f7b58c9 feat: Add SearXNG + Open WebUI web search integration
7e2ccc6 fix(scriberr-gpu): Robusteres Init-Script für SQLite readonly fix
557b3e2 Fix Scriberr GPU readonly database error
2766b69 chore: Update n8n Dockerfile
59ae5c7 Fix n8n update: remove old images before rebuild to force base image update
20e66b8 Fix n8n update by adding docker builder prune before rebuild
80be8bb Update Open Notebook to v1-latest-single tag
aa2ef12 docs: Dokumentation komplett aktualisiert für neueste Versionen
7743694 fix: open-notebook auf stabile Version 1.2.4-single umgestellt
24a3b0b fix: open-notebook API_URL auf externe IP korrigiert
907e7a8 fix: Update-System komplett überarbeitet für n8n, open-notebook und scriberr
19b2f99 fix: Update-Script verbessert für n8n und open-notebook Updates
4833f49 fix: Update-Script buildet jetzt n8n und andere Custom-Services neu
de8a192 Fix nested loop connection in YouTube workflow
4f21c68 Convert workflow to use PostgreSQL nodes instead of n8n Tables
c27e249 Fix database name in YouTube workflow setup
9e3c78c Add YouTube to Open Notebook workflow + PostgreSQL tuning
c95cfc5 Use YAML anchors for Penpot flags - matches official configuration
7c5b8cd Fix Penpot database config - add DATABASE_URI back with correct format per official docs
0ddc224 Add PENPOT_EMAIL_VERIFICATION_ENABLED=false to disable email verification
6737db9 Fix penpot-postgres-init shell syntax error - use while loop instead of until
2fd8988 Fix: Penpot PostgreSQL connection issue with special characters in password
604f6fd Docs: Complete Penpot integration with setup and MCP guides
3eb9212 Feature: Add Penpot integration
6ed3bba Feature: Migrate Perplexica to Docker Hub image for v1.1.0
3eb9212 Fix: Use dynamic SERVER_IP for Formbricks and Langfuse URLs
```

</details>
