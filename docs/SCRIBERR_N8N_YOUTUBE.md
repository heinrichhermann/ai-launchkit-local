# Scriberr + n8n YouTube Transcription Automation

This guide shows how to automate YouTube transcription using Scriberr and n8n, addressing the Scriberr v1.0.4-cuda YouTube UI authentication bug.

## Problem & Solution

**Problem:** Scriberr YouTube download via UI returns `{"error":"Missing authentication"}`

**Root Cause:** Frontend bug in Scriberr v1.0.4-cuda - JWT token not sent to YouTube API endpoint

**Solution:** Automated n8n workflow that bypasses the UI

## How It Works

```
YouTube URL → n8n Webhook → yt-dlp Download → Scriberr Upload → Transcription → Response
```

## Prerequisites

- Scriberr running (Port 8083) ✅
- n8n running (Port 8000) ✅
- yt-dlp installed in Scriberr container ✅ (auto-installed)

## n8n Workflow Setup

### Step 1: Create Webhook Trigger

```
Node: Webhook
Method: POST
Path: youtube-transcribe
Authentication: None

Request Body:
{
  "url": "https://www.youtube.com/watch?v=VIDEO_ID",
  "language": "de"
}
```

### Step 2: Download YouTube Audio

```
Node: Execute Command
Command: 
docker exec localai-scriberr-gpu-1 yt-dlp "{{ $json.body.url }}" \
  -o "/app/data/uploads/{{ $now.format('YYYYMMDDHHmmss') }}.mp3" \
  --format bestaudio --extract-audio --audio-format mp3

Output Parsing: Enabled
Extract: filename from output
```

### Step 3: Trigger Scriberr Transcription

```
Node: HTTP Request
Method: POST
URL: http://scriberr:8080/api/v1/transcription/upload
Authentication: Bearer Token (your JWT from Scriberr login)

Body (Form-Data):
- file: Binary data from downloaded audio
- title: {{ $json.body.url }}

Alternatively use Scriberr API Key (Settings → API Keys)
```

### Step 4: Monitor Transcription Status

```
Node: Wait (Loop)
Wait Time: 30 seconds
Max Iterations: 60

Then: HTTP Request
GET http://scriberr:8080/api/v1/transcription/{{ $('Step 3').json.id }}/status
```

### Step 5: Get Transcript

```
Node: HTTP Request  
Method: GET
URL: http://scriberr:8080/api/v1/transcription/{{ $('Step 3').json.id }}/transcript

Response: Full transcript with timestamps
```

### Step 6: Optional - Ollama Summary

```
Node: HTTP Request
Method: POST
URL: http://scriberr:8080/api/v1/summarize

Body:
{
  "transcription_id": "{{ $('Step 3').json.id }}",
  "template_id": null,
  "model": "qwen2.5:7b-instruct-q4_K_M"
}
```

### Step 7: Respond

```
Node: Respond to Webhook
Status: 200
Body:
{
  "status": "success",
  "transcript": "{{ $('Step 5').json.transcript }}",
  "summary": "{{ $('Step 6').json.summary }}",
  "transcription_id": "{{ $('Step 3').json.id }}"
}
```

## Usage Examples

### Curl

```bash
# Basic transcription
curl -X POST http://192.168.178.151:8000/webhook/youtube-transcribe \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://www.youtube.com/watch?v=YtyJ4reSQY0",
    "language": "de"
  }'
```

### From n8n Workflow

```
Trigger → Execute Command → HTTP Request to this webhook
```

## Scriberr API Reference

Full API documentation: https://scriberr.app/api.html

### Key Endpoints

**Upload Audio:**
```
POST /api/v1/transcription/upload
Content-Type: multipart/form-data
Authorization: Bearer YOUR_JWT_TOKEN

Response: { "id": "transcript-id", "status": "pending" }
```

**Check Status:**
```
GET /api/v1/transcription/{id}/status
Authorization: Bearer YOUR_JWT_TOKEN

Response: { "status": "completed|processing|failed" }
```

**Get Transcript:**
```
GET /api/v1/transcription/{id}/transcript
Authorization: Bearer YOUR_JWT_TOKEN

Response: Full transcript with word-level timing
```

**Create Summary:**
```
POST /api/v1/summarize
Authorization: Bearer YOUR_JWT_TOKEN

Body: {
  "transcription_id": "id",
  "model": "qwen2.5:7b-instruct-q4_K_M"
}
```

## Authentication

Scriberr API requires authentication via:
- **JWT Token** (from login) - Preferred for user actions
- **API Key** (from Settings) - Preferred for automation

### Get JWT Token

```bash
# Login and get JWT
curl -X POST http://192.168.178.151:8083/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"YOUR_USERNAME","password":"YOUR_PASSWORD"}'

# Returns: { "token": "eyJhbGc..." }
```

### Create API Key

```
1. Login to Scriberr: http://192.168.178.151:8083
2. Go to: Settings → API Keys
3. Create New API Key
4. Copy key and use in n8n: X-API-Key header
```

## Advantages Over UI

✅ **No authentication issues** - Proper API key handling
✅ **Reliable** - No UI bugs
✅ **Automation** - Full n8n integration
✅ **Batch processing** - Process multiple videos
✅ **Monitoring** - Track status programmatically

## Common Issues

### yt-dlp Download Fails

**Check yt-dlp in container:**
```bash
docker exec localai-scriberr-gpu-1 yt-dlp --version
# Should show: 2025.10.14 or newer
```

**Test manually:**
```bash
docker exec localai-scriberr-gpu-1 yt-dlp \
  "https://www.youtube.com/watch?v=VIDEO_ID" \
  -o "/app/data/uploads/test.mp3"
```

### Transcription Stuck

```bash
# Check Scriberr logs
docker logs localai-scriberr-gpu-1 --tail 50

# Check transcription queue
curl http://192.168.178.151:8083/api/v1/admin/queue/stats \
  -H "Authorization: Bearer YOUR_JWT"
```

### Ollama Not Responding

```
1. Check Ollama: http://192.168.178.151:8021
2. In Scriberr Settings → LLMs:
   - Base URL: http://ollama:11434
   - Test connection
```

## Best Practices

1. **Use API Keys** for n8n workflows (not JWT tokens)
2. **Monitor disk space** - Audio files accumulate in `shared/audio/`
3. **Clean old transcriptions** regularly
4. **Use appropriate Whisper model** - `base` for speed, `large-v3` for quality

## Future Enhancements

- [ ] Batch YouTube playlist processing
- [ ] Automatic cleanup of old audio files
- [ ] Integration with Weaviate for semantic search
- [ ] Webhook notifications on completion
- [ ] Multi-language detection

## Related Documentation

- Scriberr Troubleshooting: `docs/SCRIBERR_TROUBLESHOOTING.md`
- Scriberr API: https://scriberr.app/api.html
- n8n Workflows: http://192.168.178.151:8000

---

**Services:**
- Scriberr Web UI: http://192.168.178.151:8083
- Scriberr API: http://192.168.178.151:8083/api/v1
- n8n: http://192.168.178.151:8000
- Ollama: http://192.168.178.151:8021
