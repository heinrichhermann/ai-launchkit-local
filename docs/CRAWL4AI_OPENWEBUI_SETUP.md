# Crawl4AI + Open WebUI Integration

Diese Dokumentation beschreibt die automatische Integration von Crawl4AI als Tool Server in Open WebUI.

## Übersicht

Crawl4AI ist ein AI-powered Web Crawler und Scraper, der Webseiten intelligent extrahieren kann. Durch die Integration mit Open WebUI können Sie direkt im Chat Webseiten crawlen und deren Inhalte analysieren lassen.

### Architektur

```
┌─────────────────────────────────────────────────────────────┐
│                     Open WebUI (Port 8020)                  │
│                                                             │
│  ┌─────────────────┐    ┌─────────────────────────────────┐│
│  │   Chat UI       │    │   Tool Server Connections       ││
│  │                 │    │   (TOOL_SERVER_CONNECTIONS)     ││
│  │  "Crawl this    │───▶│                                 ││
│  │   website..."   │    │   ┌─────────────────────────┐   ││
│  │                 │    │   │ Crawl4AI (OpenAPI)      │   ││
│  └─────────────────┘    │   │ http://crawl4ai:11235   │   ││
│                         │   └─────────────────────────┘   ││
│                         └─────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────┐
│                   Crawl4AI (Port 8093)                      │
│                                                             │
│  ┌─────────────────┐    ┌─────────────────────────────────┐│
│  │ OpenAPI Spec    │    │   Web Crawler Engine            ││
│  │ /openapi.json   │    │   - Headless Browser            ││
│  │                 │    │   - Content Extraction          ││
│  │                 │    │   - Markdown Conversion         ││
│  └─────────────────┘    └─────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

## Automatische Konfiguration

Die Integration ist **out-of-the-box** für neue Installationen konfiguriert. Open WebUI verwendet die `TOOL_SERVER_CONNECTIONS` Umgebungsvariable, um Crawl4AI automatisch als Tool Server zu registrieren.

### Konfiguration in docker-compose.local.yml

```yaml
open-webui:
  environment:
    # Crawl4AI Tool Server Integration (OpenAPI)
    - ENABLE_DIRECT_CONNECTIONS=true
    - TOOL_SERVER_CONNECTIONS=[{"type":"openapi","url":"http://crawl4ai:11235","spec_type":"url","spec":"","path":"openapi.json","auth_type":"none","key":"","config":{"enable":true},"info":{"id":"crawl4ai","name":"Crawl4AI","description":"AI-powered web crawler and scraper"}}]
  depends_on:
    crawl4ai:
      condition: service_started
      required: false  # Soft dependency - Open WebUI starts even without Crawl4AI
```

### Wichtiger Hinweis: PersistentConfig

`TOOL_SERVER_CONNECTIONS` ist eine **PersistentConfig** Variable in Open WebUI. Das bedeutet:

- **Neue Installationen**: Die Konfiguration wird automatisch beim ersten Start übernommen
- **Bestehende Installationen**: Die Umgebungsvariable wird **ignoriert**, da die Konfiguration bereits in der Datenbank gespeichert ist

## Installation

### Neue Installation

1. **Crawl4AI Profil aktivieren** in `.env`:
   ```bash
   COMPOSE_PROFILES=open-webui,crawl4ai,cpu  # oder gpu-nvidia
   ```

2. **Services starten**:
   ```bash
   docker compose -f docker-compose.local.yml up -d
   ```

3. **Fertig!** Crawl4AI ist automatisch als Tool in Open WebUI verfügbar.

### Bestehende Installation

Für bestehende Open WebUI Installationen muss die Tool Server Verbindung manuell hinzugefügt werden:

1. **Open WebUI öffnen**: `http://SERVER_IP:8020`

2. **Admin Panel öffnen**: Klicken Sie auf Ihr Profil → Admin Panel

3. **Settings → Connections** navigieren

4. **Tool Server hinzufügen**:
   - **Type**: OpenAPI
   - **URL**: `http://crawl4ai:11235`
   - **Spec Type**: URL
   - **Path**: `openapi.json`
   - **Auth Type**: None
   - **Enable**: ✓

5. **Speichern** und die Seite neu laden

### Alternative: Datenbank zurücksetzen

Wenn Sie die automatische Konfiguration nutzen möchten:

```bash
# WARNUNG: Löscht alle Open WebUI Einstellungen!
docker volume rm ai-launchkit-local_open-webui
docker compose -f docker-compose.local.yml up -d open-webui
```

## Verwendung

### Im Chat

Sobald Crawl4AI als Tool verfügbar ist, können Sie es direkt im Chat verwenden:

```
User: Crawl die Webseite https://example.com und fasse den Inhalt zusammen

AI: [Verwendet Crawl4AI Tool]
    Die Webseite example.com enthält...
```

### Verfügbare Funktionen

Crawl4AI bietet folgende Funktionen über die OpenAPI-Schnittstelle:

1. **Basic Crawl**: Einfaches Crawlen einer URL
2. **Deep Crawl**: Rekursives Crawlen mit Link-Verfolgung
3. **Content Extraction**: Intelligente Inhaltsextraktion
4. **Markdown Conversion**: Konvertierung in Markdown-Format

### Beispiel-Prompts

```
# Einfaches Crawlen
"Crawl https://news.ycombinator.com und zeige mir die Top-Stories"

# Mit Inhaltsextraktion
"Extrahiere den Hauptinhalt von https://blog.example.com/article"

# Für Recherche
"Crawl diese 3 URLs und vergleiche deren Inhalte: [URL1], [URL2], [URL3]"
```

## Konfiguration

### Crawl4AI Umgebungsvariablen

In `docker-compose.local.yml`:

```yaml
crawl4ai:
  environment:
    # Ollama für LLM-basierte Extraktion
    - LLM_PROVIDER=ollama/qwen2.5:7b-instruct-q4_K_M
    - OLLAMA_API_BASE=http://ollama:11434
    # Cloud APIs deaktiviert (lokale Verarbeitung)
    - OPENAI_API_KEY=
    - ANTHROPIC_API_KEY=
```

### Ressourcen-Limits

```yaml
crawl4ai:
  shm_size: 1g  # Shared Memory für Headless Browser
  deploy:
    resources:
      limits:
        cpus: "1.0"
        memory: 4G
```

## Troubleshooting

### Tool nicht sichtbar in Open WebUI

1. **Prüfen Sie, ob Crawl4AI läuft**:
   ```bash
   docker ps | grep crawl4ai
   curl http://localhost:8093/openapi.json
   ```

2. **Prüfen Sie die Tool Server Verbindung**:
   - Admin Panel → Settings → Connections
   - Crawl4AI sollte als "Connected" angezeigt werden

3. **Logs prüfen**:
   ```bash
   docker logs crawl4ai
   docker logs open-webui | grep -i crawl
   ```

### Crawl4AI startet nicht

```bash
# Container-Status prüfen
docker compose -f docker-compose.local.yml ps crawl4ai

# Logs anzeigen
docker logs crawl4ai

# Neustart
docker compose -f docker-compose.local.yml restart crawl4ai
```

### OpenAPI-Spec nicht erreichbar

```bash
# Von innerhalb des Docker-Netzwerks testen
docker exec open-webui curl http://crawl4ai:11235/openapi.json
```

### Timeout bei großen Webseiten

Crawl4AI kann bei komplexen Webseiten länger brauchen. Die Standard-Timeouts sind:

- Open WebUI Tool Timeout: 120 Sekunden
- Crawl4AI Request Timeout: 60 Sekunden

Für längere Crawls können Sie die Timeouts in der Crawl4AI Konfiguration anpassen.

## Vergleich: Crawl4AI vs. SearXNG Web Search

| Feature | Crawl4AI | SearXNG |
|---------|----------|---------|
| **Zweck** | Einzelne Webseiten crawlen | Web-Suche über mehrere Engines |
| **Ausgabe** | Vollständiger Seiteninhalt | Suchergebnisse (Snippets) |
| **Tiefe** | Deep Crawl möglich | Nur Suchergebnisse |
| **LLM-Integration** | Intelligente Extraktion | Keine |
| **Anwendungsfall** | Dokumentation, Artikel lesen | Recherche, aktuelle Infos |

**Empfehlung**: Beide Tools ergänzen sich gut:
- **SearXNG** für Recherche und das Finden relevanter URLs
- **Crawl4AI** für das detaillierte Lesen und Analysieren gefundener Seiten

## Ports

| Service | Port | Beschreibung |
|---------|------|--------------|
| Crawl4AI | 8093 | Web Crawler API |
| Open WebUI | 8020 | Chat Interface |

## Weiterführende Links

- [Crawl4AI GitHub](https://github.com/unclecode/crawl4ai)
- [Crawl4AI Dokumentation](https://crawl4ai.com/)
- [Open WebUI Tool Servers](https://docs.openwebui.com/features/plugin/tools/)
- [SearXNG Integration](SEARXNG_OPENWEBUI_SETUP.md)
