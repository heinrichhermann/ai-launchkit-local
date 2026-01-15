# SearXNG + Open WebUI Integration Guide

This guide explains how to enable AI-powered web search in Open WebUI using SearXNG as the search backend.

## Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    AI LaunchKit Network                         │
│                                                                 │
│  ┌─────────────┐     HTTP/JSON      ┌─────────────────────┐    │
│  │  Open WebUI │ ─────────────────► │      SearXNG        │    │
│  │  (Port 8020)│ ◄───────────────── │    (Port 8089)      │    │
│  │             │   Search Results   │                     │    │
│  │  Chat + AI  │                    │  Meta Search Engine │    │
│  │  + Search   │                    │  (Google, DDG, etc) │    │
│  └─────────────┘                    └─────────────────────┘    │
│        │                                     │                  │
│        │                                     │                  │
│        ▼                                     ▼                  │
│  ┌─────────────┐                    ┌─────────────────────┐    │
│  │   Ollama    │                    │       Redis         │    │
│  │  (Port 8021)│                    │    (Port 8002)      │    │
│  │  Local LLM  │                    │   Search Cache      │    │
│  └─────────────┘                    └─────────────────────┘    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Quick Start

### 1. Enable Required Profiles

Add `open-webui` and `searxng` to your `COMPOSE_PROFILES` in `.env`:

```bash
COMPOSE_PROFILES="n8n,open-webui,searxng,cpu"
```

### 2. Start Services

```bash
cd ai-launchkit-local
docker compose up -d
```

### 3. Verify Integration

1. Open SearXNG: `http://YOUR_IP:8089`
   - Test a search query
   - Verify JSON API: `http://YOUR_IP:8089/search?q=test&format=json`

2. Open Open WebUI: `http://YOUR_IP:8020`
   - Create an account or log in
   - Start a new chat
   - Click the 🌐 (globe) icon to enable web search
   - Ask a question that requires current information

## Configuration

### Environment Variables

The following variables are pre-configured in `.env.local.example`:

```bash
# Enable web search in Open WebUI
ENABLE_WEB_SEARCH=true

# Use SearXNG as search engine
WEB_SEARCH_ENGINE=searxng

# Number of search results per query
WEB_SEARCH_RESULT_COUNT=5

# Concurrent search requests
WEB_SEARCH_CONCURRENT_REQUESTS=10

# RAG Web Search (optional)
ENABLE_RAG_WEB_SEARCH=false
RAG_WEB_SEARCH_RESULT_COUNT=3
```

### SearXNG Configuration

The SearXNG settings are in `searxng/settings-base.yml`:

```yaml
search:
  formats:
    - html
    - json  # Required for Open WebUI!
```

### Docker Compose Configuration

The integration is configured in `docker-compose.local.yml`:

```yaml
open-webui:
  environment:
    - ENABLE_WEB_SEARCH=${ENABLE_WEB_SEARCH:-true}
    - WEB_SEARCH_ENGINE=${WEB_SEARCH_ENGINE:-searxng}
    - SEARXNG_QUERY_URL=http://searxng:8080/search?q=<query>
  depends_on:
    searxng:
      condition: service_started
      required: false
```

**Important:** The URL uses `searxng:8080` (Docker internal network with container name and internal port). This works because both containers are in the same Docker Compose network. Do NOT use `host.docker.internal:8089` as this may cause connection issues on Linux servers.

## How It Works

1. **User asks a question** in Open WebUI chat
2. **User enables web search** by clicking the 🌐 icon
3. **Open WebUI sends query** to SearXNG via internal Docker network
4. **SearXNG aggregates results** from multiple search engines
5. **Results returned as JSON** to Open WebUI
6. **LLM processes results** and generates an informed response

## Features

### Web Search in Chat

- Click the 🌐 globe icon in the chat input
- Ask questions requiring current information
- AI will search the web and cite sources

### RAG Web Search (Optional)

Enable automatic web search for RAG queries:

```bash
ENABLE_RAG_WEB_SEARCH=true
```

This automatically searches the web when processing documents.

### Search Engines

SearXNG aggregates results from:
- Google
- DuckDuckGo
- Bing
- Wikipedia
- GitHub
- Stack Overflow
- arXiv
- Google Scholar
- And more...

## Troubleshooting

### Web Search Not Working

1. **Check SearXNG is running:**
   ```bash
   docker ps | grep searxng
   curl http://localhost:8089/search?q=test&format=json
   ```

2. **Check JSON format is enabled:**
   ```bash
   cat searxng/settings-base.yml | grep -A3 "formats:"
   ```

3. **Check Open WebUI logs:**
   ```bash
   docker logs open-webui 2>&1 | grep -i search
   ```

4. **Verify network connectivity:**
   ```bash
   docker exec open-webui curl -s http://searxng:8080/search?q=test&format=json | head
   ```

### SearXNG Returns Empty Results

1. **Check search engine status:**
   - Open `http://YOUR_IP:8089/stats`
   - Look for disabled or failing engines

2. **Restart SearXNG:**
   ```bash
   docker compose restart searxng
   ```

### Open WebUI Can't Connect to SearXNG

1. **Verify both services are on the same network:**
   ```bash
   docker network inspect localai_network | grep -A5 "open-webui\|searxng"
   ```

2. **Check the SEARXNG_QUERY_URL:**
   - Must use internal port: `http://searxng:8080/search?q=<query>`
   - NOT the external port 8089

## Security Considerations

### For Production Use

1. **Change SearXNG secret key:**
   ```yaml
   # In searxng/settings-base.yml
   server:
     secret_key: "your-secure-random-key"
   ```
   
   Generate with: `openssl rand -hex 32`

2. **Enable rate limiting:**
   ```yaml
   server:
     limiter: true
   ```

3. **Restrict access:**
   - Use firewall rules to limit access to port 8089
   - Or remove port mapping and keep SearXNG internal-only

## Advanced Configuration

### Custom Search Engines

Edit `searxng/settings-base.yml` to enable/disable engines:

```yaml
engines:
  - name: google
    disabled: false
  - name: bing
    disabled: true  # Disable Bing
```

### Search Result Count

Adjust in `.env`:

```bash
WEB_SEARCH_RESULT_COUNT=10  # More results
```

### Timeout Settings

In `searxng/settings-base.yml`:

```yaml
outgoing:
  request_timeout: 10.0  # Increase timeout
```

## API Reference

### SearXNG JSON API

```bash
# Basic search
curl "http://localhost:8089/search?q=query&format=json"

# With parameters
curl "http://localhost:8089/search?q=query&format=json&categories=general&language=en"
```

### Response Format

```json
{
  "query": "search query",
  "results": [
    {
      "title": "Result Title",
      "url": "https://example.com",
      "content": "Result snippet...",
      "engine": "google"
    }
  ],
  "number_of_results": 100
}
```

## Related Documentation

- [Open WebUI Documentation](https://docs.openwebui.com/)
- [SearXNG Documentation](https://docs.searxng.org/)
- [AI LaunchKit README](../README.md)

## Support

For issues specific to this integration:
1. Check the troubleshooting section above
2. Review Docker logs: `docker compose logs open-webui searxng`
3. Open an issue on the AI LaunchKit repository
