# Vibe + n8n YouTube Transcription Workflow

This guide shows how to create an automated YouTube transcription workflow using Vibe API and n8n, addressing the Scriberr YouTube UI authentication bug.

## Overview

**Problem:** Scriberr v1.0.4-cuda has a bug where YouTube downloads via UI return "Missing authentication"

**Solution:** Automated n8n workflow that:
1. Downloads YouTube videos via yt-dlp
2. Transcribes using Vibe API
3. Optionally summarizes with Ollama
4. Returns clean transcript

## Prerequisites

- Vibe service running (Port 8101)
- n8n running (Port 8000)
- Ollama running for summaries (Port 8021)

## n8n Workflow Steps

### 1. Webhook Trigger

Create a webhook that accepts YouTube URLs:

```
Node: Webhook
Method: POST
Path: youtube-transcribe
Body: {
  "url": "https://www.youtube.com/watch?v=VIDEO_ID",
  "language": "de" (optional)
}
```

### 2. Execute Command - Download YouTube Video

```
Node: Execute Command
Command: 
docker exec vibe sh -c "yt-dlp '{{$json.body.url}}' -o /app/uploads/{{$now.format('YYYYMMDDHHmmss')}}.mp3"

Output: filename
```

### 3. HTTP Request - Vibe Transcription

```
Node: HTTP Request  
Method: POST
URL: http://vibe:3022/api/v1/transcribe
Headers:
  Content-Type: multipart/form-data
Body:
  file: [uploaded audio file]
  language: {{$json.body.language}}
```

### 4. Optional: Ollama Summary

```
Node: HTTP Request
Method: POST
URL: http://ollama:11434/api/generate
Body: {
  "model": "qwen2.5:7b-instruct-q4_K_M",
  "prompt": "Summarize this transcript: {{$json.transcript}}",
  "stream": false
}
```

### 5. Respond

```
Node: Respond to Webhook
Status: 200
Body: {
  "transcript": "{{$json.transcript}}",
  "summary": "{{$json.summary}}" (optional)
}
```

## Usage Example

```bash
# Call n8n webhook
curl -X POST http://192.168.178.151:8000/webhook/youtube-transcribe \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://www.youtube.com/watch?v=YtyJ4reSQY0",
    "language": "de"
  }'
```

## Vibe API Endpoints

Full Swagger documentation: `http://192.168.178.151:8101/docs`

### Key Endpoints:

**Transcribe Audio:**
```
POST /api/v1/transcribe
Content-Type: multipart/form-data
- file: audio file
- language: language code (optional)
- model: whisper model (optional, default: base)
```

**Get Models:**
```
GET /api/v1/models
Returns list of available Whisper models
```

**Health Check:**
```
GET /health
Returns server status
```

## Advantages over Scriberr UI

✅ **No authentication issues** - Direct API access
✅ **Automation** - Integrate into workflows
✅ **Ollama integration** - Built-in AI summaries
✅ **Flexibility** - Customize transcription parameters
✅ **Reliable** - No UI bugs

## Workflow Template

A complete n8n workflow template will be added to:
`n8n/backup/workflows/YouTube_Transcription_via_Vibe_API.json`

## Troubleshooting

### Vibe Container Not Starting

```bash
# Check logs
docker logs vibe

# Common issue: Rust build failed
# Solution: Increase Docker build memory
```

### yt-dlp Not Found

```bash
# Install in Vibe container
docker exec vibe apt-get update && apt-get install -y python3 python3-pip
docker exec vibe pip3 install yt-dlp
```

### Transcription Slow

```bash
# Use smaller model
# In Vibe API request: model=tiny or small
```

## Future Enhancements

- [ ] Add speaker diarization support
- [ ] Batch YouTube playlist transcription
- [ ] Automatic subtitle generation
- [ ] Multi-language detection
- [ ] Integration with Weaviate for vector search

---

**Related Services:**
- Scriberr: http://SERVER_IP:8083 (Web UI for file uploads)
- Vibe API: http://SERVER_IP:8101 (API for automation)
- Ollama: http://SERVER_IP:8021 (AI summaries)
- n8n: http://SERVER_IP:8000 (Workflow builder)
