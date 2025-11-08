# YouTube to Open Notebook - Workflow Plan

> ⚠️ **WICHTIG:** Dies ist NUR der PLAN, keine Implementation!
> - URLs sind Beispiele/Platzhalter
> - Im echten Workflow werden alle URLs als n8n-Expressions konfiguriert
> - Die eigentliche Workflow-JSON kommt als nächstes

## 🎯 Projektziel

Automatisierte Verarbeitung von YouTube-Videos in deutsche Podcasts und Transkripte:
- **Multi-Channel Support** (unbegrenzt skalierbar)
- **Auto-Translation** (beliebige Sprache → Deutsch)
- **Thorsten Voice Podcast** (deutscher TTS)
- **Open Notebook Storage** (strukturierte Ablage)
- **100% Kostenlos** (alle AI LaunchKit Services)

---

## 🏗️ Architektur-Übersicht

### Hauptkomponenten

```
n8n Schedule Trigger (täglich 6:00)
  ↓
YouTube API (neue Videos holen)
  ↓
n8n Tables (State Management)
  ↓
Whisper (Transkription + Language Detection)
  ↓
LibreTranslate (→ Deutsch falls nötig)
  ↓
Ollama (Deutsche Summary)
  ↓
OpenedAI Speech (Thorsten Podcast)
  ↓
Open Notebook (Speicherung)
```

### Service-Nutzung (AI LaunchKit)

| Service | Port | Zweck | Status |
|---------|------|-------|--------|
| n8n | 8000 | Workflow-Orchestrierung | ✅ Installiert |
| Faster Whisper | 8080 | Video-Transkription | ✅ Installiert |
| OpenedAI Speech | 8081 | Text-to-Speech (Thorsten) | ✅ Installiert |
| LibreTranslate | 8082 | Übersetzung zu Deutsch | ✅ Installiert |
| Open Notebook | 8101 | API für Notebook-Verwaltung | ✅ Installiert |
| Ollama | 8021 | Lokale LLM (Summary) | ✅ Installiert |

---

## 📊 Datenmodell (n8n Tables)

### Table 1: `youtube_channels`

**Zweck:** Verwaltung mehrerer YouTube-Kanäle

| Spalte | Typ | Required | Beschreibung | Beispiel |
|--------|-----|----------|--------------|----------|
| `channel_id` | String | ✅ | YouTube Channel ID | `UCXuqSBlHAE6Xw-yeJA0Tunw` |
| `channel_name` | String | ✅ | Anzeigename | `Linus Tech Tips` |
| `channel_url` | String | ✅ | YouTube URL | `youtube.com/@LinusTechTips` |
| `original_language` | String | ✅ | ISO 639-1 Code | `en`, `de`, `es` |
| `enabled` | Boolean | ✅ | Aktiv? | `true` |
| `notebook_name` | String | ✅ | Open Notebook Name | `YT: Linus Tech Tips` |
| `notebook_id` | String | ❌ | Auto-generiert | `notebook_abc123` |
| `last_sync` | DateTime | ❌ | Letzter Scan | `2025-11-08 06:00` |
| `video_count` | Number | ❌ | Anzahl Videos | `1247` |
| `created_at` | DateTime | ❌ | Erstellt am | `2025-11-08` |

**Hinweis:** Benutzer fügt Channels manuell in diese Table ein!

### Table 2: `youtube_videos`

**Zweck:** Tracking aller verarbeiteten Videos

| Spalte | Typ | Required | Beschreibung |
|--------|-----|----------|--------------|
| `video_id` | String | ✅ | YouTube Video ID |
| `channel_id` | String | ✅ | Gehört zu Channel |
| `title` | String | ✅ | Video-Titel |
| `url` | String | ✅ | YouTube URL |
| `duration_seconds` | Number | ✅ | Länge in Sekunden |
| `published_date` | DateTime | ✅ | Veröffentlicht am |
| `thumbnail_url` | String | ❌ | Thumbnail URL |
| `detected_language` | String | ❌ | Von Whisper erkannt |
| `needs_translation` | Boolean | ❌ | Wenn nicht Deutsch |
| `status` | Select | ✅ | `discovered`, `transcribing`, `translating`, `summarizing`, `podcast_generating`, `completed`, `failed`, `skipped` |
| `skip_reason` | String | ❌ | Bei skipped: Grund |
| `notebook_entry_url` | String | ❌ | Link zu Open Notebook |
| `discovered_at` | DateTime | ✅ | Wann gefunden |
| `processed_at` | DateTime | ❌ | Wann fertig |
| `error_message` | String | ❌ | Falls Fehler |

---

## 🔄 Workflow-Design

### Workflow 1: "YouTube Multi-Channel to Open Notebook"

**Trigger:** Schedule (täglich 6:00 Uhr)

#### Phase 1: Channel Discovery

**Nodes:**
1. **Schedule Trigger** (nodes-base.scheduleTrigger)
   - Rule: Daily at 06:00
   - Timezone: Europe/Berlin

2. **n8n Table: Read Channels** (nodes-base.n8nTable)
   - Table: `youtube_channels`
   - Filter: `enabled = true`
   - Output: Array von aktiven Channels

3. **IF Node: Channels vorhanden?**
   - Condition: `{{$json.length > 0}}`
   - TRUE → Continue
   - FALSE → End

#### Phase 2: Video Discovery (Loop über Channels)

4. **Loop Over Items** (nodes-base.splitInBatches)
   - Batch Size: 1 (ein Channel nach dem anderen)

5. **HTTP Request: YouTube RSS Feed**
   - URL: `https://www.youtube.com/feeds/videos.xml?channel_id={{$json.channel_id}}`
   - Method: GET
   - Response: XML mit neuesten Videos

6. **Code Node: Parse YouTube RSS**
   - Input: XML Response
   - Output: Array von Video-Objekten mit:
     - video_id
     - title
     - url
     - published_date
     - duration (via YouTube API v3)

7. **n8n Table: Read Processed Videos**
   - Table: `youtube_videos`
   - Filter: `channel_id = {{$json.channel_id}}`

8. **Code Node: Filter & Classify**
   - Filtere bereits verarbeitete Videos
   - Erkenne Shorts (duration < 60 Sekunden)
   - Sortiere nach Priorität (neueste zuerst)
   - Output: Neue Videos zum Verarbeiten

#### Phase 3: Video Processing (Loop über neue Videos)

9. **Loop Over Items: Videos**
   - Batch Size: 5 (parallele Verarbeitung)

10. **Switch Node: Video Routing**
    - Case 1: `is_short = true` → Skip Branch
    - Case 2: `duration > 7200` → Skip Branch (>2h)
    - Default: Process Branch

**Skip Branch:**
11. **n8n Table: Insert Skipped**
    - Table: `youtube_videos`
    - Status: `skipped`
    - Skip Reason: `is_short` oder `too_long`

**Process Branch:**
12. **HTTP Request: Whisper API**
    - URL: `http://faster-whisper:8000/v1/audio/transcriptions`
    - Method: POST
    - Body: `{"url": "{{$json.url}}", "language": "auto"}`
    - Response: Transkript + detected_language

13. **IF Node: Translation nötig?**
    - Condition: `{{$json.language !== "de"}}`
    - TRUE → Translate Branch
    - FALSE → Skip to Summary

**Translation Branch:**
14. **HTTP Request: LibreTranslate**
    - URL: `http://libretranslate:5000/translate`
    - Method: POST
    - Body: `{"q": "{{$json.text}}", "source": "{{$json.language}}", "target": "de"}`
    - Output: Deutscher Text

**Summary Branch:**
15. **HTTP Request: Ollama Summary**
    - URL: `http://ollama:11434/api/generate`
    - Method: POST
    - Model: `qwen2.5:7b-instruct-q4_K_M`
    - Prompt: "Erstelle eine deutsche Management Summary (300 Wörter)..."

16. **HTTP Request: Open Notebook Create/Add**
    - URL: `http://open-notebook:5055/api/notebooks`
    - Method: POST
    - Body:
      ```json
      {
        "name": "YT: {{$node['n8n Table: Read Channels'].json.channel_name}}",
        "content": {
          "video_id": "{{$json.video_id}}",
          "title": "{{$json.title}}",
          "transcript_de": "{{$json.transcript_german}}",
          "summary_de": "{{$json.summary}}",
          "metadata": {
            "original_language": "{{$json.detected_language}}",
            "published": "{{$json.published_date}}",
            "duration": "{{$json.duration_seconds}}",
            "url": "{{$json.url}}"
          }
        }
      }
      ```

17. **HTTP Request: OpenedAI Speech (Podcast)**
    - URL: `http://openedai-speech:8000/v1/audio/speech`
    - Method: POST
    - Body:
      ```json
      {
        "model": "tts-1",
        "voice": "thorsten",
        "input": "{{$json.summary}}"
      }
      ```
    - Output: MP3 Audio

18. **HTTP Request: Open Notebook Upload Audio**
    - URL: `http://open-notebook:5055/api/notebooks/{{$json.notebook_id}}/files`
    - Method: POST
    - File: Podcast MP3

19. **n8n Table: Update Video Status**
    - Table: `youtube_videos`
    - Status: `completed`
    - Felder:
      - `processed_at`: NOW()
      - `notebook_entry_url`: Response URL
      - `detected_language`: Von Whisper

#### Phase 4: Error Handling

20. **Error Trigger Node**
    - Fängt alle Fehler ab
    - Loggt Error Message
    - Schreibt in n8n Table:
      - Status: `failed`
      - Error Message

21. **Optional: Notification**
    - HTTP Request zu Mailpit
    - Oder: Telegram Bot
    - Inhalt: Täglicher Report

---

## 🎛️ Konfiguration

### Workflow-Variablen (in config/workflow_config.json)

```json
{
  "processing": {
    "output_language": "de",
    "podcast_voice": "thorsten",
    "batch_size": 5,
    "wait_between_batches": 10,
    "max_videos_per_run": 50
  },
  
  "filtering": {
    "min_duration_seconds": 300,
    "max_duration_seconds": 7200,
    "exclude_shorts": true,
    "exclude_livestreams": true
  },
  
  "summary": {
    "length_words": 300,
    "style": "professional",
    "include_timestamps": true,
    "language": "de"
  },
  
  "podcast": {
    "voice": "thorsten",
    "speed": 1.0,
    "format": "mp3"
  }
}
```

---

## 🚦 Verarbeitungs-Logik

### Shorts-Erkennung

```javascript
function isShort(video) {
  // YouTube Shorts sind IMMER unter 60 Sekunden
  if (video.duration_seconds >= 60) {
    return false;
  }
  
  // Zusätzliche Indikatoren:
  const hasShortHashtag = 
    video.title.toLowerCase().includes('#shorts') ||
    video.description.toLowerCase().includes('#shorts');
  
  return true; // Unter 60 Sekunden = Short
}
```

### Language Detection & Translation

```javascript
// Whisper gibt zurück: {text: "...", language: "en"}
const transcript = whisperResponse;

if (transcript.language !== 'de') {
  // Übersetze mit LibreTranslate
  const germanTranscript = await translate(
    transcript.text,
    transcript.language,
    'de'
  );
  return germanTranscript;
}

return transcript.text; // Bereits deutsch
```

### Batch Processing

```javascript
// Verarbeite 5 Videos parallel
const batches = chunk(newVideos, 5);

for (const batch of batches) {
  // Parallel processing
  await Promise.all(batch.map(processVideo));
  
  // Warte 10 Sekunden zwischen Batches
  await sleep(10000);
}
```

---

## 📈 Performance-Schätzungen

### Pro Video (30 Minuten Länge)

| Phase | Dauer | Service |
|-------|-------|---------|
| Transkription | ~5 Min | Whisper |
| Translation | ~1 Min | LibreTranslate |
| Summary | ~30 Sek | Ollama |
| Podcast TTS | ~3 Min | OpenedAI Speech |
| Upload | ~10 Sek | Open Notebook |
| **Total** | **~10 Min** | |

### Tägliche Kapazität

**Bei 24h Laufzeit:**
- Max Videos: ~144 Videos/Tag (10 Min/Video)
- Empfohlen: ~50 Videos/Tag (für Puffer)

**Mit Batch-Processing (5 parallel):**
- Effektiv: ~250 Videos/Tag möglich

---

## 🔌 API-Endpoints

### YouTube Data API v3

**Channel Videos RSS:**
```
GET https://www.youtube.com/feeds/videos.xml?channel_id={CHANNEL_ID}
```

**Video Details:**
```
GET https://www.googleapis.com/youtube/v3/videos
  ?part=snippet,contentDetails
  &id={VIDEO_ID}
  &key={API_KEY}
```

### Whisper API (faster-whisper-server)

**Transkription:**
```http
POST http://faster-whisper:8000/v1/audio/transcriptions
Content-Type: application/json

{
  "url": "https://youtube.com/watch?v=VIDEO_ID",
  "language": "auto",
  "response_format": "json"
}

Response:
{
  "text": "Full transcript...",
  "language": "en",
  "duration": 1832
}
```

### LibreTranslate

**Übersetzung:**
```http
POST http://libretranslate:5000/translate
Content-Type: application/json

{
  "q": "Text to translate...",
  "source": "en",
  "target": "de",
  "format": "text"
}

Response:
{
  "translatedText": "Übersetzter Text..."
}
```

### Ollama

**Summary Generation:**
```http
POST http://ollama:11434/api/generate
Content-Type: application/json

{
  "model": "qwen2.5:7b-instruct-q4_K_M",
  "prompt": "Erstelle eine deutsche Management Summary...",
  "stream": false
}

Response:
{
  "response": "Deutsche Zusammenfassung..."
}
```

### OpenedAI Speech

**Podcast TTS:**
```http
POST http://openedai-speech:8000/v1/audio/speech
Content-Type: application/json

{
  "model": "tts-1",
  "voice": "thorsten",
  "input": "Text für Podcast...",
  "response_format": "mp3"
}

Response: Binary MP3 data
```

### Open Notebook API

**Create Notebook:**
```http
POST http://open-notebook:5055/api/notebooks
Content-Type: application/json

{
  "name": "YT: Channel Name",
  "description": "Auto-generated from YouTube"
}

Response:
{
  "id": "notebook_123",
  "name": "YT: Channel Name"
}
```

**Add Content:**
```http
POST http://open-notebook:5055/api/notebooks/{id}/content
Content-Type: application/json

{
  "title": "Video Title",
  "content": "Markdown content...",
  "metadata": {
    "video_url": "...",
    "language": "de"
  }
}
```

**Upload File:**
```http
POST http://open-notebook:5055/api/notebooks/{id}/files
Content-Type: multipart/form-data

file: podcast.mp3
```

---

## ⚠️ Error Handling

### Fehler-Typen & Recovery

| Fehler | Ursache | Recovery-Strategie |
|--------|---------|-------------------|
| YouTube API Rate Limit | >10k requests/day | Wait 1h, retry |
| Whisper Timeout | Video >2h | Skip, mark failed |
| Translation Error | Nicht unterstützte Sprache | Use original, mark warning |
| Ollama Timeout | Overload | Retry 3x mit Backoff |
| TTS Error | Text zu lang | Chunken, retry |
| Open Notebook Error | API down | Retry 3x, dann fail |

### Retry-Logik

```javascript
async function withRetry(fn, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      await sleep(Math.pow(2, i) * 1000); // Exponential backoff
    }
  }
}
```

---

## 📝 Node-Liste (Workflow)

### Benötigte n8n Nodes (21 Nodes total)

| # | Node Type | Name | Zweck |
|---|-----------|------|-------|
| 1 | Schedule Trigger | Daily Trigger | Täglich 6:00 |
| 2 | n8n Table | Read Channels | Aktive Channels |
| 3 | IF | Has Channels? | Prüfe ob Channels |
| 4 | Loop Over Items | Channel Loop | Für jeden Channel |
| 5 | HTTP Request | YouTube RSS | Neue Videos holen |
| 6 | Code | Parse RSS XML | Videos extrahieren |
| 7 | HTTP Request | YouTube API Details | Duration holen |
| 8 | n8n Table | Read Processed | Bereits verarbeitet |
| 9 | Code | Filter & Classify | Neue + Shorts filtern |
| 10 | Loop Over Items | Video Loop | Für jedes Video |
| 11 | Switch | Route by Type | Short/Regular/Processed |
| 12 | n8n Table | Insert Skipped | Shorts markieren |
| 13 | HTTP Request | Whisper API | Transkription |
| 14 | IF | Needs Translation? | Sprache prüfen |
| 15 | HTTP Request | LibreTranslate | Zu Deutsch |
| 16 | HTTP Request | Ollama Summary | Deutsche Summary |
| 17 | HTTP Request | Open Notebook | Notebook erstellen/update |
| 18 | HTTP Request | OpenedAI TTS | Podcast generieren |
| 19 | HTTP Request | Open Notebook File | Audio hochladen |
| 20 | n8n Table | Update Status | completed |
| 21 | Error Trigger | Error Handler | Fehler abfangen |

---

## 🧪 Test-Szenario

### Initial Test (Manuell)

**Schritt 1: Test-Channel hinzufügen**
```
In n8n Table "youtube_channels":
- channel_id: UCXuqSBlHAE6Xw-yeJA0Tunw (Linus Tech Tips)
- channel_name: Linus Tech Tips
- channel_url: youtube.com/@LinusTechTips
- original_language: en
- enabled: true
- notebook_name: YT: Linus Tech Tips
```

**Schritt 2: Manueller Workflow-Start**
- Klicke "Execute Workflow" in n8n
- Beobachte Logs
- Prüfe n8n Tables für neue Einträge

**Schritt 3: Validierung**
1. Öffne Open Notebook (http://192.168.178.151:8100)
2. Prüfe ob Notebook erstellt wurde
3. Prüfe ob Video-Eintrag vorhanden
4. Teste Podcast-Audio
5. Prüfe deutsches Transkript

### Produktiv-Test

**Schritt 1: Mehrere Channels**
- Füge 3-5 verschiedene Channels hinzu
- Verschiedene Sprachen (en, de, es)

**Schritt 2: Schedule aktivieren**
- Lasse über Nacht laufen
- Morgens: Prüfe Ergebnisse

**Schritt 3: Performance-Monitoring**
- Wie viele Videos wurden verarbeitet?
- Gab es Fehler?
- Wie lange hat es gedauert?

---

## 🎯 Nächste Schritte

1. ✅ **Plan erstellt** (dieses Dokument)
2. ⏳ **Workflow JSON erstellen**
   - Alle 21 Nodes konfigurieren
   - Connections definieren
   - Credentials-Platzhalter
3. ⏳ **Table Schemas erstellen**
   - youtube_channels.json
   - youtube_videos.json
4. ⏳ **README.md schreiben**
   - Installation
   - Konfiguration
   - Troubleshooting
5. ⏳ **Test & Iterate**

---

## ⚙️ Technische Details

### YouTube API Quota

**Kostenlose Limits:**
- 10,000 requests/day
- Videos.list: 1 Quota pro Request
- Channels.list: 1 Quota pro Request

**Für 100 Videos/Tag:**
- RSS Feed: 0 Quota (kostenlos!)
- Video Details: 100 Quota
- **Total: 100/10,000 = 1% genutzt** ✅

### Whisper Performance

**faster-whisper-server (CPU):**
- ~0.3x Realtime (30 Min Video = 10 Min Processing)
- Parallele Requests: Möglich
- Memory: ~2GB pro Request

### LibreTranslate

**Übersetzungs-Geschwindigkeit:**
- ~1000 Zeichen/Sekunde
- 30k Zeichen Transkript = 30 Sekunden

### Ollama Summary

**qwen2.5:7b-instruct:**
- ~20 Tokens/Sekunde
- 300 Wörter Summary = ~15 Sekunden

### OpenedAI Speech (Thorsten)

**TTS Generation:**
- ~0.5x Realtime (10 Min Text = 5 Min Audio)
- Max Input: ~5000 Zeichen pro Request

---

## 💰 Kosten-Vergleich

### Cloud vs. AI LaunchKit (100 Videos/Monat)

| Service | Cloud (OpenAI/Google) | AI LaunchKit | Ersparnis |
|---------|----------------------|--------------|-----------|
| Whisper (30 Min/Video) | $180/Monat | **€0** | €180 |
| Translation (50k Wörter) | $100/Monat | **€0** | €100 |
| Summary (100k Tokens) | $50/Monat | **€0** | €50 |
| TTS (100k Zeichen) | $150/Monat | **€0** | €150 |
| Storage | $20/Monat | **€0** | €20 |
| **TOTAL** | **$500/Monat** | **€0** | **€500** 🎉

---

## 📋 Implementierungs-Checkliste

- [ ] Workflow JSON erstellt
- [ ] Table Schemas definiert
- [ ] README.md geschrieben
- [ ] Test-Channel eingefügt
- [ ] Erster Test durchgeführt
- [ ] Error Handling getestet
- [ ] Multi-Channel Test
- [ ] Produktiv-Deployment
- [ ] Monitoring Setup
- [ ] Dokumentation vervollständigt

---

**Stand:** 8.11.2025, 13:31 Uhr
**Autor:** AI Assistant (Cline)
**Review:** Pending User Approval
