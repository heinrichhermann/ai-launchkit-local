# Open Notebook - Umfassende Anleitung & Use Cases

> **📍 Hinweis zur SERVER_IP:** 
> `${SERVER_IP}` ist Ihre Server-IP-Adresse, die während der Installation konfiguriert wurde.
> Finden Sie den Wert in Ihrer `.env` Datei.
> 
> **Beispiel:** Bei Server-IP `192.168.178.151` ist der Zugriff: `http://192.168.178.151:8100`

## 🎯 Inhaltsverzeichnis

- [Schnellstart](#schnellstart)
- [Konfiguration](#konfiguration)
  - [CPU vs GPU für Speech Services](#cpu-vs-gpu-für-speech-services)
  - [Models in der UI konfigurieren](#models-in-der-ui-konfigurieren)
- [Use Cases](#use-cases)
  - [🎙️ Deutsche Podcasts erstellen](#-deutsche-podcasts-erstellen)
  - [📺 YouTube Videos transkribieren](#-youtube-videos-transkribieren)
  - [📄 PDF Research & Analyse](#-pdf-research--analyse)
  - [🔄 Advanced Workflows](#-advanced-workflows)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

---

## 🚀 Schnellstart

### Installation

Open Notebook ist bereits in AI LaunchKit integriert:

```bash
# Wizard ausführen
sudo bash scripts/04_wizard_local.sh

# "Open Notebook" auswählen
# Bei "Speech Stack" → GPU wählen für 4-5x schnellere Performance
```

### Zugriff

- **UI:** `http://${SERVER_IP}:8100`
- **API:** `http://${SERVER_IP}:8101`
- **API Docs:** `http://${SERVER_IP}:8101/docs`

---

## ⚙️ Konfiguration

### CPU vs GPU für Speech Services

**Performance-Vergleich:**

| Hardware | Podcast (27 Segmente) | YouTube (10 Min) | Empfehlung |
|----------|----------------------|------------------|------------|
| **CPU** | ~90 Sekunden | ~3 Minuten | Standard-Server |
| **GPU** | ~20 Sekunden | ~45 Sekunden | NVIDIA GPU vorhanden |

**GPU aktivieren (wenn NVIDIA GPU vorhanden):**

```bash
cd ~/ai-launchkit-local

# In .env ändern:
# Von: COMPOSE_PROFILES="...,speech,..."
# Zu:  COMPOSE_PROFILES="...,speech-gpu,..."

# Services neu starten
sudo docker compose -p localai -f docker-compose.local.yml down faster-whisper openedai-speech
sudo docker compose -p localai -f docker-compose.local.yml pull faster-whisper-gpu openedai-speech-gpu
sudo docker compose -p localai -f docker-compose.local.yml up -d faster-whisper-gpu openedai-speech-gpu
```

### Models in der UI konfigurieren

Nach dem ersten Start: **`http://${SERVER_IP}:8100`**

#### 1️⃣ Embedding Model (KRITISCH für PDFs!)

**Settings → Models → "+ Add Model" bei Embeddings:**
```
Provider: ollama
Model Name: nomic-embed-text
Display Name: Ollama Embeddings
```

**Warum wichtig:** Ohne Embedding Model können PDFs nicht durchsucht werden!

#### 2️⃣ Speech-to-Text Model

**Settings → Models → "+ Add Model" bei Speech-to-Text:**
```
Provider: openai_compatible
Model Name: whisper-1
Display Name: Local Whisper STT
```

#### 3️⃣ Text-to-Speech Model

**Settings → Models → "+ Add Model" bei Text-to-Speech:**
```
Provider: openai_compatible
Model Name: tts-1
Display Name: Local TTS
```

#### 4️⃣ AI Chat & Transformation Models

**Settings → AI Models → Ollama hinzufügen:**
```
Provider: Ollama
Base URL: http://ollama:11434
Models: qwen2.5:7b-instruct-q4_K_M
```

---

## 📚 Use Cases

### 🎙️ Deutsche Podcasts erstellen

#### Schritt 1: Speaker Profile mit gültigen Voices

**Podcasts → Speaker Profiles → "+ New Profile"**

```
Name: Deutscher Speaker
Description: Deutschsprachiger Podcast-Speaker

Speaker Configuration:
┌─────────────────────────────────────┐
│ Speaker 1 (Host):                   │
│ - Name: Moderator                   │
│ - Voice: alloy ✅                   │
│ - Role: Deutscher Podcast-Moderator │
│ - Personality: Professionell, freundlich │
└─────────────────────────────────────┘
```

**Verfügbare Voices (alle sprechen Deutsch!):**
- `alloy` - Neutral, ausgewogen
- `echo` - Männlich, warm
- `fable` - Männlich, kräftig
- `onyx` - Männlich, tief ✨ **Empfohlen für deutsche Podcasts**
- `nova` - Weiblich, freundlich
- `shimmer` - Weiblich, weich

**⚠️ WICHTIG:** Voice muss ein gültiger Name sein (z.B. `alloy`), **NICHT** eine Nummer wie `1`!

#### Schritt 2: Episode Profile für deutsche Podcasts

**Podcasts → Episode Profiles → "+ New Profile"**

```
Name: Deutscher Podcast
Number of Speakers: 2

Default Briefing:
──────────────────────────────────────────────────────
Erstelle einen professionellen deutschen Podcast über die gegebenen Quellen.

WICHTIG: Die GESAMTE Konversation muss auf Deutsch sein!

Der Podcast soll:
- Informativ aber zugänglich sein
- Die Hauptpunkte der Quellen behandeln
- Natürliche Gesprächsdynamik haben
- Fachbegriffe erklären

Host-Rolle:
- Stellt kluge Fragen
- Leitet die Diskussion
- Fasst Kernpunkte zusammen

Expert-Rolle:
- Gibt fundierte Antworten
- Erklärt Details
- Bringt praktische Beispiele
──────────────────────────────────────────────────────

Outline Model: qwen2.5:7b-instruct-q4_K_M (ollama)
Transcript Model: qwen2.5:7b-instruct-q4_K_M (ollama)
Speaker Profile: Deutscher Speaker (von oben)
```

#### Schritt 3: Podcast generieren

1. **Öffne ein Notebook** mit deutschen Quellen (PDF, YouTube, etc.)
2. **Klicke "Generate Podcast"**
3. **Wähle Quellen** aus
4. **Wähle "Deutscher Podcast" Profile**
5. **Generate**

**Ergebnis:** 
- ✅ Transcript komplett auf Deutsch
- ✅ Audio mit deutschen Stimmen
- ✅ Natürliche deutsche Konversation

#### Troubleshooting: Podcast bleibt auf Englisch

**Problem:** LLM generiert trotz Briefing englischen Text

**Lösung:** Verstärke die deutsche Anweisung im Briefing:

```
KRITISCH: Dieser Podcast MUSS zu 100% auf Deutsch sein!
Jeder Satz, jede Einleitung, jede Frage und Antwort auf DEUTSCH!
Kein einziges englisches Wort verwenden!

Beispiel-Dialog auf Deutsch:
Host: "Willkommen zum heutigen Podcast..."
Expert: "Vielen Dank für die Einladung..."
```

---

### 📺 YouTube Videos transkribieren

#### Use Case: YouTube Video → Durchsuchbare Transkription

**Schritt 1: Video als Quelle hinzufügen**

```
1. Neues Notebook erstellen: "YouTube Research"
2. Add Source → URL
3. YouTube-Link eingeben: https://www.youtube.com/watch?v=VIDEO_ID
4. Submit
```

**Was passiert automatisch:**
- ✅ Video wird analysiert
- ✅ Audio wird extrahiert
- ✅ Whisper (lokal!) transkribiert das Audio
- ✅ Text wird in Embeddings konvertiert
- ✅ Video ist durchsuchbar

**Performance:**
- CPU: ~3 Minuten für 10-Minuten-Video
- GPU: ~45 Sekunden für 10-Minuten-Video

#### Use Case: YouTube → Zusammenfassung

**Schritt 2: Mit Video-Content chatten**

```
Chat-Prompt:
──────────────────────────────────────
Erstelle eine strukturierte Zusammenfassung dieses YouTube-Videos auf Deutsch:

1. Hauptthemen (3-5 Punkte)
2. Wichtigste Erkenntnisse
3. Praktische Takeaways
4. Zitate mit Zeitstempeln

Format: Markdown mit Überschriften
──────────────────────────────────────
```

**Ergebnis:** Strukturierte Zusammenfassung mit Quellenangaben und Zeitstempeln!

#### Use Case: YouTube → Deutscher Podcast

**Schritt 3: Podcast aus YouTube-Video generieren**

```
1. YouTube-Video ist als Quelle im Notebook
2. Generate Podcast
3. Profile: "Deutscher Podcast" wählen
4. Generate

Ergebnis: Professioneller deutscher Podcast über das YouTube-Video!
```

**Praktisches Beispiel:**
- Englisches Tech-Video auf YouTube
- Deutsches Transkript und Podcast erstellen
- Perfekt für Content-Lokalisierung!

---

### 📄 PDF Research & Analyse

#### Use Case: Einzelnes PDF analysieren

**Schritt 1: PDF hochladen**

```
1. Notebook erstellen: "Dokument-Analyse"
2. Add Source → Upload File
3. PDF auswählen
4. Upload

Automatisch:
- ✅ Text wird extrahiert
- ✅ Mit Ollama Embeddings verarbeitet
- ✅ Durchsuchbar und chatbar
```

#### Use Case: Mit PDF chatten

**Praktische Chat-Prompts:**

```
📋 Zusammenfassung:
──────────────────
Fasse dieses Dokument in 5 Kernpunkten zusammen.
Nutze Stichpunkte und sei präzise.

❓ Spezifische Fragen:
──────────────────
Was sagt das Dokument über [Thema]?
Zitiere relevante Stellen mit Seitenangabe.

🔍 Analyse:
──────────────────
Analysiere die Argumentation in diesem Dokument.
Identifiziere Stärken und Schwächen.

📊 Vergleich (mit mehreren PDFs):
──────────────────
Vergleiche die Ansätze in Dokument A und B bezüglich [Thema].
```

#### Use Case: Insights generieren

**Features → Create Insight:**

```
Insight-Types:
- Summary: Zusammenfassung des gesamten Dokuments
- Key Points: Hauptpunkte als Liste
- Questions: Generiere Fragen zum Dokument
- Action Items: Handlungsempfehlungen
```

#### Use Case: Multi-PDF Research

**Workflow:**

```
1. Notebook: "Literatur-Review"
2. Mehrere PDFs hochladen (Paper, Artikel, etc.)
3. Cross-Reference Prompts:

   "Welche Gemeinsamkeiten haben die Papers bezüglich [Methode]?"
   "Finde Widersprüche zwischen den Quellen."
   "Erstelle eine vergleichende Tabelle der Ansätze."
```

**Open Notebook zitiert automatisch die richtigen PDFs!**

---

### 🔄 Advanced Workflows

#### Workflow 1: YouTube → Blog Post

```
1. YouTube-Video als Quelle hinzufügen
2. Automatische Transkription
3. Transformation erstellen:

Prompt:
──────────────────────────────────────
Erstelle einen deutschen Blog-Post basierend auf diesem Video:

- Catchy Titel und Einleitung
- 3-4 Hauptabschnitte mit Überschriften
- Praktische Beispiele aus dem Video
- Call-to-Action am Ende
- Markdown-Format

Zielgruppe: Deutschsprachige Tech-Community
Ton: Professionell aber zugänglich
──────────────────────────────────────

4. Ergebnis: Fertiger Blog-Post auf Deutsch!
```

#### Workflow 2: Research → Podcast

```
1. Notebook mit Multiple Sources:
   - 3 PDFs über AI
   - 2 YouTube Videos
   - 5 Artikel

2. Generate Podcast:
   - Episode Profile: Deutscher Podcast
   - Speakers: 3 (Moderator + 2 Experten)
   
3. Ollama erstellt:
   - Outline über alle Quellen
   - Synthesis der Informationen
   - Natürlicher deutscher Dialog
   
4. TTS generiert:
   - Audio für alle 3 Speaker
   - GPU-beschleunigt in Minuten
   - Professional klingendes Ergebnis
```

#### Workflow 3: n8n Automatisierung

**n8n Workflow für automatisches YouTube-Processing:**

```
1. [Webhook] - YouTube-URL empfangen
2. [HTTP Request] → Open Notebook API
   POST /api/sources
   Body: { "url": "{{$json.youtube_url}}", "notebook_id": "..." }
   
3. [Wait] 2 Minuten (für Transkription)

4. [HTTP Request] → Generate Summary
   POST /api/notebooks/{{notebook_id}}/chat
   Body: { "message": "Erstelle deutsche Zusammenfassung" }
   
5. [HTTP Request] → Generate Podcast
   POST /api/notebooks/{{notebook_id}}/podcast
   Body: { "episode_profile": "Deutscher Podcast" }
   
6. [Slack/Email] → Benachrichtigung mit Links

Ergebnis: Vollautomatische YouTube → Podcast Pipeline!
```

**API-Beispiele:** Siehe `http://${SERVER_IP}:8101/docs`

---

## 💡 Best Practices

### 1. Podcast-Produktion

**✅ DO:**
- Nutze GPU-Version für schnellere Generierung (4-5x)
- Spezifiziere Sprache explizit im Briefing ("auf Deutsch!")
- Verwende verschiedene Voices für verschiedene Speaker
- Teste mit kurzen Quellen zuerst
- Setze klare Rollen für jeden Speaker

**❌ DON'T:**
- Voice-ID als Nummer (z.B. `1`) - nutze Namen (`alloy`)
- Zu lange Quellen ohne Chunking (max. 10.000 Wörter)
- GPT-5 extended thinking Modelle für Podcasts (verursacht Fehler)
- Mehrsprachige Prompts (entweder Deutsch ODER Englisch)

### 2. YouTube-Verarbeitung

**Optimale Einstellungen:**

```yaml
Whisper Model: Systran/faster-distil-whisper-large-v3
Compute: GPU (wenn verfügbar)
Chunk Size: 30 Sekunden
Language: auto-detect

Performance-Tipp:
- Videos > 30 Min: In mehrere Notebooks aufteilen
- Livestreams: In 10-Min-Segmente teilen
```

### 3. PDF-Analyse

**Embedding-Strategie:**

```
Kleine PDFs (<50 Seiten):
  Embedding Model: nomic-embed-text (Ollama)
  Chunk Size: 1000 Tokens
  
Große PDFs (>100 Seiten):
  Embedding Model: nomic-embed-text
  Chunk Size: 500 Tokens
  Split-Strategie: Nach Überschriften
  
Performance:
  CPU: ~30 Sekunden pro 10 Seiten
  Mit Ollama: Unbegrenzte Embeddings kostenlos!
```

### 4. Prompt-Engineering für deutsche Ausgabe

**Effektive Prompts:**

```
❌ Schlecht:
"Erstelle einen Podcast"
(→ wird wahrscheinlich englisch)

✅ Gut:
"Erstelle einen professionellen deutschen Podcast.
ALLE Dialoge müssen auf Deutsch sein.
Beispiel: 'Willkommen zum Podcast über...'"
(→ LLM versteht die Erwartung klar)

✅ Optimal:
"Du bist ein deutscher Podcast-Producer.
Erstelle einen informativen Podcast auf Deutsch über [Thema].
Der Host ist deutscher Muttersprachler und spricht nur Deutsch.
Der Experte antwortet ausschließlich auf Deutsch.

Beginne mit: 'Herzlich willkommen...'"
(→ Maximale Klarheit + Beispiel)
```

### 5. Resource Management

**GPU Memory Monitoring:**

```bash
# GPU-Auslastung überwachen
watch -n 2 nvidia-smi

# Bei mehreren GPUs: Spezifische GPU wählen
# (bereits in docker-compose.local.yml konfiguriert)

# Memory-Nutzung:
- faster-whisper: ~256MB VRAM
- openedai-speech: ~512MB VRAM (beim Generieren)
- Gesamt: ~1GB VRAM ausreichend
```

---

## 🎬 Praktische Szenarien

### Szenario 1: Wöchentlicher News-Podcast

**Setup:**

```
1. Episode Profile: "Tech News DE"
   Briefing: "Erstelle einen dynamischen deutschen Tech-News Podcast.
             Host fasst Nachrichten zusammen, Experte analysiert Auswirkungen."
   Speakers: 2 (alloy + onyx)
   
2. Wöchentlicher Workflow:
   - Montag: 5 Tech-Artikel als Quellen hinzufügen
   - Podcast generieren (GPU: ~2 Minuten)
   - Audio herunterladen
   - Auf Plattformen veröffentlichen
   
3. Automatisierung (optional):
   - n8n Workflow: RSS → Open Notebook → Podcast
   - Automatischer Upload zu Podcast-Plattform
```

### Szenario 2: Uni-Vorlesung transkribieren

**Setup:**

```
1. Vorlesungs-Video (YouTube oder Upload)
2. Automatische Transkription mit Whisper GPU
3. Ergebnis:
   - Durchsuchbares Transkript
   - Timestamps für Navigation
   - Chat mit Vorlesungsinhalten
   
4. Lern-Funktionen:
   - "Erkläre Konzept X aus der Vorlesung"
   - "Erstelle Zusammenfassung für Prüfung"
   - "Generiere Flashcards"
```

### Szenario 3: Unternehmens-Documentation

**Setup:**

```
1. Notebook: "Firmen-Dokumentation"
2. Quellen:
   - PDFs: Richtlinien, Prozesse, Verträge
   - Videos: Onboarding, Trainings
   - Artikel: Best Practices
   
3. Use Cases:
   - Mitarbeiter-Onboarding: "Was muss ich über [Prozess] wissen?"
   - Compliance: "Finde alle Regeln zu [Thema]"
   - Podcast: "Erstelle deutsche Einführung für neue Mitarbeiter"
```

### Szenario 4: Content Repurposing

**Workflow:**

```
Ausgangspunkt: 1 langes YouTube-Video (45 Min, Englisch)

↓ Open Notebook Processing

Ergebnisse:
  ├─ Deutsches Transkript (Whisper)
  ├─ Deutsche Zusammenfassung (Ollama)
  ├─ Deutscher Podcast (10 Min, TTS)
  ├─ Blog-Post auf Deutsch (Transformation)
  ├─ Social Media Posts (Kurz-Zusammenfassungen)
  └─ FAQ (Generiert aus Inhalt)

Time: ~10 Minuten (mit GPU)
Cost: 0€ (alles lokal!)
```

---

## 🔧 Troubleshooting

### Problem: "Missing required models: Embedding Model"

**Ursache:** Kein Embedding Model konfiguriert

**Lösung:**
```
Settings → Models → Embedding Model:
- Provider: ollama
- Model Name: nomic-embed-text
```

### Problem: Podcast-Audio Fehler "KeyError: '1'"

**Ursache:** Ungültige Voice-ID im Speaker Profile

**Lösung:**
```
Podcasts → Speaker Profiles → Profile bearbeiten
- Ändere Voice von "1" → "alloy" (oder andere gültige Voice)
- Gültig: alloy, echo, fable, onyx, nova, shimmer
- Ungültig: Zahlen oder custom Namen
```

### Problem: Podcast bleibt Englisch trotz deutschem Briefing

**Ursache:** LLM ignoriert Sprachanweisung

**Lösung:**
```
1. Verstärke Anweisung im Briefing:
   "KRITISCH: 100% DEUTSCH! Kein Englisch!"
   
2. Gib Beispiel-Dialoge auf Deutsch:
   "Host: 'Herzlich willkommen zum Podcast...'"
   
3. Falls weiterhin Probleme:
   - Nutze stärkeres Modell (z.B. GPT-4o via API)
   - Oder erstelle Outline manuell auf Deutsch
```

### Problem: YouTube-Transkription schlägt fehl

**Ursache:** Video nicht verfügbar, Copyright, oder zu lang

**Lösung:**
```
1. Prüfe Video-URL im Browser
2. Bei Copyright-Videos: Download und Upload als File
3. Lange Videos (>2h): In Teile splitten:
   
   # YouTube-Video herunterladen
   yt-dlp -f "best[height<=720]" VIDEO_URL
   
   # In 30-Min Segmente teilen
   ffmpeg -i video.mp4 -c copy -map 0 -segment_time 1800 -f segment segment_%03d.mp4
   
   # Einzeln in Open Notebook hochladen
```

### Problem: Slow Performance trotz GPU

**Diagnose:**

```bash
# Prüfe ob GPU wirklich genutzt wird
docker logs faster-whisper 2>&1 | grep -i "device"
# Sollte zeigen: "device=cuda" NICHT "device=cpu"

docker logs openedai-speech 2>&1 | grep -i cuda
# Sollte CUDA-Version zeigen

# GPU-Auslastung während Generierung
nvidia-smi
# Sollte >0% GPU-Util zeigen während Podcast generiert wird
```

**Lösungen:**

```
1. Falsch konfiguriert:
   - Prüfe COMPOSE_PROFILES in .env: muss "speech-gpu" sein
   - Container neu erstellen: sudo docker compose ... up -d --force-recreate

2. GPU Memory voll:
   - Andere GPU-Prozesse beenden
   - Oder auf zweite GPU umstellen

3. Alte Container laufen noch:
   docker ps -a | grep faster-whisper
   # Alle alten Container löschen
```

### Problem: DNS Fehler bei PDF-Processing

**Fehler:** `[Errno -3] Temporary failure in name resolution`

**Ursache:** Ollama nicht erreichbar oder kein Embedding Model

**Lösung:**

```bash
# 1. Prüfe Ollama Verbindung
docker exec open-notebook curl -s http://ollama:11434/api/tags

# 2. Prüfe ob Embedding Model in UI konfiguriert ist
# Settings → Models → Embedding Model muss gesetzt sein!

# 3. Prüfe Docker Netzwerk
docker network inspect localai_network | grep -E "open-notebook|ollama"
# Beide müssen im selben Netzwerk sein

# 4. Container im richtigen Projekt starten
sudo docker compose -p localai -f docker-compose.local.yml restart open-notebook
```

---

## 📊 Performance-Benchmarks

**Hardware:** 2x NVIDIA RTX 3090, AMD Ryzen, 128GB RAM

| Task | CPU | GPU | Speedup |
|------|-----|-----|---------|
| YouTube 10 Min transkribieren | 180s | 45s | **4.0x** |
| Podcast generieren (27 Segmente) | 90s | 20s | **4.5x** |
| PDF embedden (50 Seiten) | 30s | 30s | 1.0x ¹ |

¹ *Embedding läuft auf Ollama (CPU), nicht auf Speech Services*

**Empfehlung:**
- **Speech Services:** GPU für Podcasts & Transkription
- **Ollama:** GPU für Embeddings & Chat (wenn genug VRAM)
- **Kombination:** Größter Performance-Gewinn!

---

## 🔗 API Integration

### REST API Beispiele

**Podcast programmatisch erstellen:**

```python
import requests

# 1. Source hochladen
response = requests.post(
    f"http://{SERVER_IP}:8101/api/sources",
    files={"file": open("dokument.pdf", "rb")},
    data={"notebook_id": "notebook:xxx"}
)
source_id = response.json()["id"]

# 2. Podcast generieren
response = requests.post(
    f"http://{SERVER_IP}:8101/api/podcasts/generate",
    json={
        "notebook_id": "notebook:xxx",
        "source_ids": [source_id],
        "episode_profile": "Deutscher Podcast",
        "name": "Mein Podcast"
    }
)

episode_id = response.json()["episode_id"]

# 3. Audio herunterladen
audio_url = f"http://{SERVER_IP}:8101/api/podcasts/episodes/{episode_id}/audio"
```

**Vollständige API-Dokumentation:** `http://${SERVER_IP}:8101/docs`

---

## 🎓 Tipps & Tricks

### Tipp 1: Episode Profile Templates

**Interview-Style (2 Speaker):**
```
Host: alloy (neutral)
Guest: nova (freundlich)
Briefing: "Informatives Interview, Host stellt Fragen"
```

**Panel-Diskussion (3 Speaker):**
```
Moderator: alloy
Expert 1: onyx (autoritativ)
Expert 2: echo (warm)
Briefing: "Lebhafte Diskussion mit verschiedenen Perspektiven"
```

**Solo-Präsentation (1 Speaker):**
```
Presenter: fable (kräftig)
Briefing: "Klare, strukturierte Präsentation der Inhalte"
```

### Tipp 2: Ollama Model-Auswahl

```
Für Chat & Zusammenfassungen:
  qwen2.5:7b-instruct-q4_K_M ✅
  - Schnell
  - Gute deutsche Qualität
  - 4GB VRAM
  
Für Embeddings:
  nomic-embed-text ✅
  - Spezialisiert für Embeddings
  - Sehr schnell
  - 1GB VRAM
  
Für lange Dokumente:
  qwen2.5:14b (wenn genug VRAM)
  - Bessere Qualität
  - Längerer Context
  - 8GB VRAM
```

### Tipp 3: Multi-Source Strategie

**Organizational Pattern:**

```
Projekt-Notebook/
├── Research Papers (10 PDFs)
├── YouTube Tutorials (5 Videos)
├── Expert Interviews (3 Audio Files)
└── Articles (15 Web Pages)

Workflow:
1. Alle Quellen hinzufügen
2. Tags vergeben (z.B. "basics", "advanced", "case-study")
3. Filtern nach Tags für spezifische Podcasts
4. Cross-Reference Analyse möglich
```

### Tipp 4: Backup-Strategie

```bash
# Open Notebook Daten sichern
cd ~/ai-launchkit-local

# Wichtige Verzeichnisse:
./open-notebook/data/      # Uploaded files, embeddings
./open-notebook/surreal/   # SurrealDB (alle Notebooks, Settings)

# Backup erstellen
tar -czf open-notebook-backup-$(date +%Y%m%d).tar.gz open-notebook/

# Bei Kopia-Backup automatisch mit erfasst!
```

---

## 🌟 Advanced Features

### Feature: Custom Transformations

**Eigene Content-Transformationen erstellen:**

```
Settings → Transformations → "+ New Transformation"

Name: Deutsche Executive Summary
Prompt:
──────────────────────────────────────
Erstelle eine Executive Summary auf Deutsch:

1. Situation (2 Sätze)
2. Problem (2 Sätze)
3. Lösung (3 Sätze)
4. Empfehlung (2 Sätze)

Format: Professionell, prägnant, Entscheider-Sprache
Max. 150 Wörter
──────────────────────────────────────

Anwendung: Bei jeder Quelle verfügbar als Quick Action!
```

### Feature: Speaker Personalities

**Charakterisierte Speaker erstellen:**

```
Speaker: "Deutscher Tech-Erklärer"
┌────────────────────────────────────────────┐
│ Role: Deutscher Tech-Journalist            │
│                                            │
│ Personality:                               │
│ - Erklärt komplexe Konzepte einfach       │
│ - Nutzt Analogien und Beispiele           │
│ - Enthusiastisch aber nicht übertrieben   │
│ - Spricht perfektes Hochdeutsch           │
│                                            │
│ Voice: onyx                                │
│ Style: Professionell, zugänglich          │
└────────────────────────────────────────────┘

Ergebnis: Konsistenter Character über alle Podcasts!
```

---

## 📈 Performance-Optimierung

### GPU-Optimierung

**Optimale docker-compose Konfiguration:**

```yaml
# GPU-Version aktiviert beide Speech Services mit CUDA
openedai-speech-gpu:
  image: ghcr.io/matatonic/openedai-speech:latest
  environment:
    - NVIDIA_VISIBLE_DEVICES=all
    - NVIDIA_DRIVER_CAPABILITIES=compute,utility

faster-whisper-gpu:
  image: fedirz/faster-whisper-server:latest-cuda
  environment:
    - WHISPER__DEVICE=cuda
    - WHISPER__COMPUTE_TYPE=float16
```

**Verifikation:**

```bash
# CUDA-Nutzung prüfen
docker logs faster-whisper 2>&1 | grep "CUDA Version"
# Output: CUDA Version 12.2.2 ✅

# GPU Memory während Podcast-Generierung
nvidia-smi
# faster-whisper: ~256MB
# openedai-speech: ~512MB (während Generierung)
```

### Ollama-Optimierung

**Model Quantization für bessere Performance:**

```bash
# Auf Ubuntu Server
docker exec ollama ollama list

# Empfohlene Modelle:
qwen2.5:7b-instruct-q4_K_M  # Balanced (4GB VRAM)
qwen2.5:7b-instruct-q8_0    # Higher Quality (7GB VRAM)
qwen2.5:14b-instruct-q4_K_M # Best Quality (8GB VRAM)
```

---

## 🌐 Weiterführende Links

- **[Setup-Dokumentation](OPEN_NOTEBOOK_SETUP.md)** - Installation und Grundkonfiguration
- **[TTS Integration](OPEN_NOTEBOOK_TTS_INTEGRATION.md)** - Speech Services Detailkonfiguration
- **[Open Notebook GitHub](https://github.com/lfnovo/open-notebook)** - Upstream-Projekt
- **[API Dokumentation](http://${SERVER_IP}:8101/docs)** - REST API Reference

---

## 📝 Zusammenfassung

### Was Sie mit Open Notebook + AI LaunchKit erreichen:

✅ **Komplett lokale AI-Verarbeitung:**
- Keine Cloud-API-Kosten
- Volle Datenkontrolle
- Unbegrenzte Nutzung

✅ **Deutsche Content-Produktion:**
- YouTube → Deutscher Podcast
- PDF → Deutsche Zusammenfassung
- Multi-Source → Deutscher Blog-Post

✅ **GPU-Beschleunigung:**
- 4-5x schnellere Verarbeitung
- Professional Audio-Qualität
- Minuten statt Stunden

✅ **Automatisierung:**
- n8n Integration
- REST API für Custom Workflows
- Batch-Processing möglich

### Nächste Schritte:

1. ✅ Models in UI konfigurieren (Ollama, STT, TTS, Embeddings)
2. ✅ Deutscher Podcast-Profile erstellen
3. ✅ Ersten Podcast generieren und testen
4. 🚀 Advanced Workflows mit n8n automatisieren

**Viel Erfolg mit Open Notebook!** 🎙️

---

*Dokumentation erstellt: Oktober 2025 | AI LaunchKit Version: Latest*
