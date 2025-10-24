# Open Notebook - NotebookLM Alternative Setup

> **📍 Hinweis zur SERVER_IP:** 
> `${SERVER_IP}` ist eine Variable, die während der Installation automatisch erkannt 
> oder manuell konfiguriert wird. Sie finden den Wert in Ihrer `.env` Datei.
> 
> **Beispiel:** Wenn Ihr Ubuntu Server die IP `192.168.1.50` hat, dann wäre der 
> Zugriff: `http://192.168.1.50:8100`

> **📚 NEU: Umfassende Anleitung verfügbar!**
> 
> Für detaillierte Use Cases, Best Practices und Schritt-für-Schritt Anleitungen siehe:
> **[Open Notebook - Umfassende Anleitung & Use Cases](OPEN_NOTEBOOK_GUIDE.md)**
>
> Themen: Deutsche Podcasts, YouTube Transkription, PDF Research, API Integration, Performance-Optimierung

## 🎯 Was ist Open Notebook?

Open Notebook ist eine **vollständige, selbst-gehostete Alternative zu Google's NotebookLM**. Es bietet erweiterte Features für AI-gestützte Recherche, Podcast-Generierung und Wissensmanagement.

### 🌟 Hauptfeatures

- 📚 **Multi-Notebook Organisation**: Mehrere Forschungsprojekte parallel verwalten
- 🔒 **Privacy-First**: Alle Daten bleiben auf deinem Server
- 🎙️ **Podcast Generation**: Professionelle Multi-Speaker Podcasts aus deinen Quellen
- 🤖 **Multi-Model Support**: 16+ AI Provider (OpenAI, Anthropic, Ollama, Groq, etc.)
- 📄 **Universal Content**: PDFs, Videos, Audio, Webseiten, Office Docs
- 💬 **Context-Aware Chat**: KI-Gespräche basierend auf deinen Quellen
- 🔍 **Intelligente Suche**: Volltext und Vektorsuche
- 📝 **AI-Assisted Notes**: Automatische oder manuelle Notizen

## 🚀 Installation

Open Notebook ist bereits in AI LaunchKit integriert!

### Im Wizard aktivieren:

```bash
sudo bash scripts/install_local.sh
# Oder bei bestehender Installation:
sudo bash scripts/04_wizard_local.sh
```

Wähle im Wizard:
```
☑ Open Notebook (NotebookLM Alternative) - Ports 8100, 8101
```

### Manuelle Aktivierung in .env:

```bash
# Füge "open-notebook" zu COMPOSE_PROFILES hinzu:
COMPOSE_PROFILES="n8n,flowise,monitoring,open-notebook"
```

## 🔧 Konfiguration

### Notwendige Umgebungsvariablen (.env):

```bash
# AI Provider (mindestens einer erforderlich)
OPENAI_API_KEY=sk-...          # Für OpenAI Modelle
ANTHROPIC_API_KEY=sk-ant-...   # Für Claude Modelle
GROQ_API_KEY=gsk-...            # Für schnelle Inference

# Datenbank Passwort (wird automatisch generiert)
OPEN_NOTEBOOK_DB_PASSWORD=auto-generated-password
```

### Optional: Ollama Integration

Open Notebook kann auch **lokale Modelle** über Ollama nutzen:

```bash
# In docker-compose bereits konfiguriert:
OLLAMA_API_BASE_URL=http://ollama:11434
```

**Voraussetzung:**
- Ollama muss aktiv sein (cpu, gpu-nvidia, oder gpu-amd Profile)
- Modelle müssen gepullt sein (z.B. qwen2.5:7b-instruct-q4_K_M)

## 📡 Zugriff

### Frontend UI
```
http://${SERVER_IP}:8100
```

### REST API
```
http://${SERVER_IP}:8101
```

### API Dokumentation
```
http://${SERVER_IP}:8101/docs
```

**Architektur:** Open Notebook nutzt ein Single-Container-Setup mit zwei exponierten Ports:
- Port **8100**: Frontend UI (Next.js)
- Port **8101**: Backend API (FastAPI)

Beide Services laufen im selben Container, aber auf separaten Ports für saubere Trennung.

## 🎯 Erste Schritte

### 1. Neues Notebook erstellen
- Öffne http://${SERVER_IP}:8100
- Klicke auf "New Notebook"
- Gib einen Namen ein

### 2. Quellen hinzufügen
Unterstützte Formate:
- 📄 **Dokumente**: PDF, DOCX, TXT, MD
- 🎥 **Videos**: YouTube URLs, lokale Videos
- 🎙️ **Audio**: MP3, WAV, etc.
- 🌐 **Webseiten**: Beliebige URLs
- 📊 **Office**: PPTX, XLSX

### 3. Mit deinen Quellen chatten
- Stelle Fragen basierend auf deinen Quellen
- Erhalte Antworten mit Quellenangaben
- Wechsle zwischen verschiedenen AI-Modellen

### 4. Podcasts generieren
- Wähle Quellen aus
- Konfiguriere Speaker (1-4 Speaker)
- Generiere professionelle Audio-Diskussionen

## 🤖 AI Model Konfiguration

### Provider Setup in Open Notebook

Nach dem ersten Start:

1. **Gehe zu Settings (⚙️)**
2. **Wähle "AI Models"**
3. **Konfiguriere Provider:**

#### OpenAI Setup:
```
Provider: OpenAI
API Key: (automatisch aus .env übernommen)
Models: gpt-4o, gpt-4o-mini, gpt-3.5-turbo
```

#### Anthropic (Claude) Setup:
```
Provider: Anthropic
API Key: (automatisch aus .env übernommen)
Models: claude-3-5-sonnet, claude-3-opus
```

#### Ollama Setup (Lokal):
```
Provider: Ollama
Base URL: http://ollama:11434
Models: qwen2.5:7b-instruct-q4_K_M, llama3.2, etc.
```

#### Groq Setup (Schnell):
```
Provider: Groq
API Key: (automatisch aus .env übernommen)
Models: llama-3.3-70b, mixtral-8x7b
```

## 📊 Features im Detail

### Content Transformations

Erstelle **Custom Actions** um Content zu verarbeiten:

**Beispiele:**
- Zusammenfassungen generieren
- Schlüsselpunkte extrahieren
- Übersetzungen erstellen
- Fragen generieren

### Podcast Generation

**Advanced Multi-Speaker Podcasts:**

1. **Episode Profiles erstellen:**
   - 1 Speaker: Monolog/Präsentation
   - 2 Speaker: Interview/Dialog
   - 3-4 Speaker: Panel-Diskussion

2. **Speaker Charakteristiken:**
   - Name und Rolle definieren
   - Stimm-Charakter festlegen
   - Persönlichkeit beschreiben

3. **Generation:**
   - Wähle Quellen
   - Wähle Episode Profile
   - Generiere Audio

### Search & Citations

**Drei Suchtypen:**
- **Volltext-Suche**: Schnelle Keyword-Suche
- **Vector-Suche**: Semantische Ähnlichkeitssuche
- **Hybrid**: Kombiniert beides

**Citations:**
- Jede AI-Antwort enthält Quellenangaben
- Klicke auf Zitate um zur Originalstelle zu springen
- Verifiziere Informationen direkt an der Quelle

## 🔄 Integration mit AI LaunchKit

### n8n Workflows

Open Notebook kann über die REST API mit n8n automatisiert werden:

**Beispiel Workflow:**
```
1. Webhook empfängt Dokument
2. HTTP Request → Open Notebook API (Upload)
3. HTTP Request → Open Notebook API (Process & Analyze)
4. Ergebnis speichern oder weiterverarbeiten
```

**API Endpoints:**
- POST `/api/sources` - Quelle hochladen
- POST `/api/notebooks/{id}/chat` - Mit Notebook chatten
- POST `/api/notebooks/{id}/podcast` - Podcast generieren
- GET `/api/search` - Suche durchführen

Siehe: http://${SERVER_IP}:8101/docs für vollständige API-Dokumentation

### Ollama Integration

Wenn Ollama aktiv ist, kann Open Notebook es automatisch nutzen:

**Vorteile:**
- ✅ Komplett offline Betrieb
- ✅ Keine API-Kosten
- ✅ Unlimitierte Anfragen
- ✅ Volle Datenkontrolle

**Setup:**
1. Ollama Profile aktivieren (cpu/gpu-nvidia/gpu-amd)
2. Modelle pullen: `docker exec ollama ollama pull qwen2.5:7b-instruct-q4_K_M`
3. In Open Notebook Settings → AI Models → Ollama konfigurieren

## 📁 Datenstruktur

Open Notebook speichert Daten in:

```
./open-notebook/
├── data/           # Hochgeladene Dateien, Embeddings
└── surreal/        # SurrealDB Datenbank
```

**Backup:**
Diese Verzeichnisse sollten regelmäßig gesichert werden!

## 🔍 Troubleshooting

### Service startet nicht

```bash
# Logs prüfen:
docker logs open-notebook

# Häufige Probleme:
# 1. API Key fehlt
grep OPENAI_API_KEY .env

# 2. Port-Konflikt
netstat -tuln | grep 8100

# 3. Container neu starten
docker compose -p localai -f docker-compose.local.yml restart open-notebook
```

### Ollama Connection Failed

```bash
# Prüfe ob Ollama läuft:
docker ps | grep ollama

# Teste Ollama Verbindung:
docker exec open-notebook curl -s http://ollama:11434/api/tags

# Falls nicht erreichbar, Ollama neu starten:
docker compose -p localai -f docker-compose.local.yml restart ollama-cpu
# oder
docker compose -p localai -f docker-compose.local.yml restart ollama-gpu
```

### Podcast Generation Fehler

**Problem:** "Invalid JSON output"

**Lösung:**
- Nutze GPT-4o, GPT-4o-mini oder GPT-4-turbo
- Vermeide GPT-5 extended thinking Modelle
- Siehe: [Open Notebook GPT-5 Issue](https://github.com/lfnovo/open-notebook/pull/155)

### Database Connection Error

```bash
# SurrealDB Volume prüfen:
ls -la open-notebook/surreal/

# Falls leer, initialisieren:
docker compose -p localai -f docker-compose.local.yml down open-notebook
rm -rf open-notebook/surreal/
docker compose -p localai -f docker-compose.local.yml up -d open-notebook
```

## 🎓 Best Practices

### 1. Notebook-Organisation

**Pro Projekt ein Notebook:**
- Research-Projekt A → Notebook A
- Research-Projekt B → Notebook B

**Vorteile:**
- Saubere Trennung der Kontexte
- Bessere Organisation
- Schnellere Suche

### 2. Quellenmanagement

**Beschreibende Namen:**
- ❌ `document.pdf`
- ✅ `Whitepaper_AI_Trends_2025.pdf`

**Tags nutzen:**
- Kategorisiere Quellen mit Tags
- Schnelleres Filtern
- Bessere Übersicht

### 3. AI Model Auswahl

**Für Recherche:**
- GPT-4o-mini: Schnell und günstig
- GPT-4o: Beste Qualität
- Claude 3.5 Sonnet: Exzellent für Analyse

**Für Podcasts:**
- GPT-4o: Empfohlen
- GPT-4-turbo: Gut und günstiger
- Ollama Qwen2.5: Offline-Option

### 4. Performance-Optimierung

**Bei großen Dokumenten:**
- Aktiviere "Smart Chunking"
- Nutze höhere Context-Limits
- Wähle effiziente Embedding-Modelle

## 🔗 Weiterführende Links

- [Open Notebook GitHub](https://github.com/lfnovo/open-notebook)
- [Open Notebook Website](https://www.open-notebook.ai)
- [Open Notebook Docs](https://github.com/lfnovo/open-notebook/tree/main/docs)
- [API Documentation](http://${SERVER_IP}:8101/docs)
- [Discord Community](https://discord.gg/37XJPXfz2w)

## 📝 Vergleich: Open Notebook vs Google NotebookLM

| Feature | Open Notebook | Google NotebookLM |
|---------|--------------|-------------------|
| **Hosting** | Self-hosted | Google Cloud |
| **Privacy** | 100% privat | Cloud-basiert |
| **AI Provider** | 16+ Provider wählbar | Nur Google |
| **Podcast Speakers** | 1-4 Speaker | 2 Speaker fix |
| **API Zugriff** | Voll REST API | Kein API |
| **Kosten** | Nur AI-Nutzung | Subscription + Nutzung |
| **Offline** | Ja (mit Ollama) | Nein |
| **Anpassbar** | Open Source | Closed System |

## 🆕 Neue Features in v1.0

- ✨ **Next.js Frontend**: Moderne React UI
- 🚀 **REST API**: Vollständiger programmatischer Zugriff
- 📱 **Dark Mode**: Augenschonende Oberfläche
- ⚡ **Async Processing**: Schnellere Verarbeitung
- 🔄 **Live Updates**: Echtzeit UI-Updates (bald)
- 📎 **Cross-Notebook Sources**: Quellen über Projekte hinweg nutzen (bald)

## 💡 Tipps & Tricks

### Content Transformation Beispiele

**Zusammenfassung erstellen:**
```
Create a comprehensive summary of this document highlighting:
- Main arguments
- Key findings  
- Actionable insights
```

**FAQ generieren:**
```
Based on this content, generate a FAQ with:
- 10 most common questions
- Clear, concise answers
- Source references
```

### Podcast Script Customization

**Interview Style:**
```
Host: Expert interviewer, asks probing questions
Guest: Subject matter expert, provides detailed answers
```

**Panel Discussion:**
```
Moderator: Guides discussion
Expert 1: Technical perspective
Expert 2: Business perspective  
Expert 3: User perspective
```

## 🔐 Sicherheit

### Zugriffskontrolle

Open Notebook unterstützt **optionale Passwort-Authentifizierung**:

**Aktivieren:**
1. In Settings → Security
2. "Password Protection" aktivieren
3. Passwort setzen

**Für öffentliche Deployments empfohlen!**

### Daten-Verschlüsselung

- ✅ SurrealDB ist lokal gespeichert
- ✅ Keine Cloud-Uploads
- ✅ HTTPS möglich (via Reverse Proxy)

## 🎨 Anwendungsfälle

### Akademische Recherche
- Paper-Analyse und Zusammenfassung
- Literatur-Review erstellen
- Podcast-Präsentationen generieren

### Business Intelligence
- Marktanalyse durchführen
- Wettbewerber-Research
- Trend-Identifikation

### Content Creation
- Blog-Posts aus Research erstellen
- Podcast-Inhalte generieren
- Social Media Content ableiten

### Persönliches Wissensmanagement
- Lern-Notizen organisieren
- Bücher zusammenfassen
- Video-Transkripte durchsuchbar machen
