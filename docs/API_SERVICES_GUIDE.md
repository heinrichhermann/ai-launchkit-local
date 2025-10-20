# API Services Nutzungsanleitung

Dieser Guide erklärt die korrekte Nutzung der API-only Services im AI LaunchKit.

## 🔍 Übersicht

Einige Services im AI LaunchKit sind **reine APIs** ohne Web-Interface. Sie sind für die Verwendung aus **n8n Workflows** oder **direkten API-Calls** konzipiert.

### API-Only Services (kein Web-Interface):
- ✅ **EasyOCR** (Port 8085) - Text-Erkennung API
- ✅ **Tesseract OCR** (Port 8084) - Schnelle OCR API  
- ✅ **OpenedAI TTS** (Port 8081) - Text-to-Speech API
- ✅ **Chatterbox TTS** (Port 8087) - Advanced TTS API (API-only, UI auf :8088)
- ✅ **Qdrant** (Port 8026) - Vector DB API (Dashboard: /dashboard)
- ✅ **Weaviate** (Port 8027) - Vector DB API

---

## 📄 EasyOCR API (Port 8085)

### Problem
Beim direkten Öffnen von `http://SERVER_IP:8085` erscheint:
```
404 Not Found
The requested URL was not found on the server.
```

### Lösung: API-Endpoints verwenden

EasyOCR ist eine **reine API** ohne Web-Interface.

### ✅ Korrekte Nutzung

#### 1. Health Check
```bash
curl http://SERVER_IP:8085/health
```

#### 2. OCR durchführen (Base64)
```bash
curl -X POST http://SERVER_IP:8085/ocr \
  -H "Content-Type: application/json" \
  -d '{
    "image": "BASE64_ENCODED_IMAGE_HERE",
    "languages": ["en", "de"]
  }'
```

#### 3. OCR durchführen (File Upload)
```bash
curl -X POST http://SERVER_IP:8085/ocr \
  -F "file=@/path/to/image.jpg" \
  -F "languages=en,de"
```

### 📝 n8n Integration

Verwende den **HTTP Request Node**:

```javascript
// n8n HTTP Request Node Konfiguration
{
  "method": "POST",
  "url": "http://easyocr:2000/ocr",
  "bodyType": "formData",
  "sendBody": true,
  "specifyBody": "formData",
  "bodyParameters": {
    "file": "={{$binary.data}}",
    "languages": "en,de"
  }
}
```

---

## 📝 Tesseract OCR API (Port 8084)

### Problem
JSON Parsing Error beim Upload:
```
{"error":"Request input validation failed","reason":"SyntaxError: Unexpected token u in JSON at position 0"}
```

### Ursache
Tesseract erwartet eine **spezielle Request-Struktur** (nicht einfaches JSON).

### ✅ Korrekte Nutzung

#### 1. Status prüfen
```bash
curl http://SERVER_IP:8084/status
```

#### 2. OCR durchführen (Multipart Form)
```bash
curl -X POST http://SERVER_IP:8084/recognize \
  -F "file=@document.pdf" \
  -F "lang=deu+eng" \
  -F "psm=3" \
  -F "oem=3"
```

**Parameter:**
- `lang`: Sprache (deu, eng, fra, etc.)
- `psm`: Page Segmentation Mode (0-13)
- `oem`: OCR Engine Mode (0-3)

#### 3. Verfügbare Sprachen
```bash
curl http://SERVER_IP:8084/languages
```

### 📝 n8n Integration

```javascript
// n8n HTTP Request Node für Tesseract
{
  "method": "POST",
  "url": "http://tesseract-ocr:8884/recognize",
  "bodyType": "formData",
  "sendBody": true,
  "bodyParameters": {
    "file": "={{$binary.data}}",
    "lang": "deu+eng",
    "psm": "3",
    "oem": "3"
  }
}
```

### 🔍 PSM Modi (Page Segmentation Mode)
- `0`: Orientation and script detection (OSD) only
- `1`: Automatic page segmentation with OSD
- `3`: **Fully automatic** (empfohlen für die meisten Fälle)
- `6`: Assume a single uniform block of text
- `11`: Sparse text (einzelne Wörter)

---

## 🎙️ OpenedAI TTS API (Port 8081)

### Problem
Leere Seite beim Öffnen von `http://SERVER_IP:8081`

### Lösung: OpenAI-kompatible API

OpenedAI TTS ist eine **OpenAI-kompatible TTS API** ohne Web-Interface.

### ✅ Korrekte Nutzung

#### 1. OpenAI-kompatible Anfrage
```bash
curl http://SERVER_IP:8081/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d '{
    "model": "tts-1",
    "input": "Hello, this is a test.",
    "voice": "alloy",
    "response_format": "mp3"
  }' \
  --output speech.mp3
```

#### 2. Verfügbare Stimmen
- alloy
- echo
- fable
- onyx
- nova
- shimmer

### 📝 n8n Integration

```javascript
// n8n HTTP Request Node für OpenedAI TTS
{
  "method": "POST",
  "url": "http://openedai-speech:8000/v1/audio/speech",
  "authentication": "none",
  "bodyType": "json",
  "sendBody": true,
  "jsonParameters": {
    "model": "tts-1",
    "input": "={{$json.text}}",
    "voice": "alloy",
    "response_format": "mp3"
  },
  "responseType": "binary"
}
```

### 🔧 Modell-Auswahl
- `tts-1`: Standard-Qualität (schneller)
- `tts-1-hd`: Hohe Qualität (langsamer)

---

## 🎤 Chatterbox TTS (Port 8087)

### Problem
"Not Found" beim Öffnen von `http://SERVER_IP:8087`

### Lösung: API + separates Frontend

Chatterbox besteht aus 2 Komponenten:
- **API**: Port 8087 (nur API)
- **Frontend UI**: Port 8088 (Web-Interface)

### ✅ Korrekte Nutzung

#### Web-Interface nutzen:
```
http://SERVER_IP:8088
```

#### Direkte API:
```bash
curl -X POST http://SERVER_IP:8087/tts \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${CHATTERBOX_API_KEY}" \
  -d '{
    "text": "Hello world",
    "voice": "default"
  }' \
  --output audio.wav
```

### 📝 n8n Integration

```javascript
{
  "method": "POST",
  "url": "http://chatterbox-tts:4123/tts",
  "headers": {
    "X-API-Key": "={{$env.CHATTERBOX_API_KEY}}"
  },
  "bodyType": "json",
  "jsonParameters": {
    "text": "={{$json.text}}",
    "voice": "default"
  },
  "responseType": "binary"
}
```

---

## 🗄️ Qdrant Vector Database (Port 8026)

### ✅ Web Dashboard
```
http://SERVER_IP:8026/dashboard
```

### API Endpoints
```bash
# Collections auflisten
curl http://SERVER_IP:8026/collections \
  -H "api-key: ${QDRANT_API_KEY}"

# Vector suchen
curl -X POST http://SERVER_IP:8026/collections/{collection}/points/search \
  -H "Content-Type: application/json" \
  -H "api-key: ${QDRANT_API_KEY}" \
  -d '{
    "vector": [0.1, 0.2, 0.3, ...],
    "limit": 10
  }'
```

---

## 🔗 Service URLs - Zusammenfassung

| Service | Web-Interface | API Endpoint | Nutzung |
|---------|--------------|--------------|---------|
| **EasyOCR** | ❌ Keine UI | `http://SERVER_IP:8085/ocr` | API-only, n8n empfohlen |
| **Tesseract** | ❌ Keine UI | `http://SERVER_IP:8084/recognize` | API-only, n8n empfohlen |
| **OpenedAI TTS** | ❌ Keine UI | `http://SERVER_IP:8081/v1/audio/speech` | OpenAI-kompatibel |
| **Chatterbox API** | ❌ Keine UI | `http://SERVER_IP:8087/tts` | API mit separater UI |
| **Chatterbox UI** | ✅ Port 8088 | - | Web-Interface für Chatterbox |
| **Qdrant** | ✅ Port 8026/dashboard | `http://SERVER_IP:8026/collections` | Dashboard + API |
| **Whisper** | ✅ Port 8080/docs | `http://SERVER_IP:8080/v1/audio/transcriptions` | Swagger UI + API |

---

## 💡 Best Practices

### 1. Verwende n8n für API-Services
Alle API-only Services sind optimal für **n8n Workflows**:
- Keine manuelle Coding nötig
- Visual Workflow Builder
- Error Handling eingebaut
- Logging und Debugging

### 2. Service-Health vor Nutzung prüfen
```bash
# EasyOCR
curl http://SERVER_IP:8085/health

# Tesseract  
curl http://SERVER_IP:8084/status

# Whisper
curl http://SERVER_IP:8080/health
```

### 3. Verwende Container-Namen in n8n
Innerhalb des Docker-Netzwerks verwende Container-Namen:
```
http://easyocr:2000/ocr       # statt SERVER_IP:8085
http://tesseract-ocr:8884/recognize  # statt SERVER_IP:8084
http://openedai-speech:8000/v1/audio/speech  # statt SERVER_IP:8081
```

---

## 🚀 Beispiel n8n Workflow: OCR Pipeline

```
1. Webhook Trigger (empfängt PDF/Bild)
   ↓
2. HTTP Request → Tesseract OCR
   URL: http://tesseract-ocr:8884/recognize
   Method: POST
   Body: FormData mit file
   ↓
3. Set Node (Text extrahieren)
   ↓
4. HTTP Request → OpenAI (Text analysieren)
   ↓
5. Database speichern
```

---

## ❓ Troubleshooting

### "Not Found" Fehler
✅ **Normal für API-only Services** - nutze die dokumentierten Endpoints

### "Connection Refused"
```bash
# Prüfe ob Service läuft:
docker ps | grep servicename

# Prüfe Logs:
docker logs servicename
```

### JSON Parsing Errors (Tesseract)
✅ Verwende **FormData** (multipart/form-data), nicht JSON

### Leere Seite (OpenedAI TTS)
✅ Keine UI vorhanden - nutze API-Endpoint direkt oder via n8n

---

## 📚 Weiterführende Links

- [EasyOCR API Docs](https://github.com/JaidedAI/EasyOCR)
- [Tesseract OCR Server](https://github.com/hertzg/tesseract-server)
- [OpenedAI Speech](https://github.com/matatonic/openedai-speech)
- [Chatterbox TTS](https://github.com/travisvn/chatterbox-tts-api)
- [Qdrant Docs](https://qdrant.tech/documentation/)
