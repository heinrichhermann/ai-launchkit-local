# YouTube to Open Notebook - Automatische Video-Verarbeitung

## 🎯 Was macht dieser Workflow?

Automatisierte Pipeline für YouTube-Videos:
- ✅ **Scannt YouTube-Kanäle** täglich nach neuen Videos
- ✅ **Transkribiert** Videos mit Whisper (lokal)
- ✅ **Übersetzt** zu Deutsch mit LibreTranslate
- ✅ **Erstellt Summary** mit Ollama (lokal)
- ✅ **Generiert Podcast** mit Thorsten Voice (deutsch)
- ✅ **Speichert alles** in Open Notebook

**100% kostenlos, 100% lokal, keine Cloud-Services!**

---

## 📋 Voraussetzungen

### AI LaunchKit Services (müssen laufen)

Prüfe auf deinem Server:
```bash
docker ps | grep -E "n8n|faster-whisper|openedai-speech|libretranslate|open-notebook|ollama"
```

**Benötigt:**
- ✅ n8n (Port 8000)
- ✅ Faster Whisper (Port 8080)
- ✅ OpenedAI Speech (Port 8081)
- ✅ LibreTranslate (Port 8082)
- ✅ Open Notebook (Port 8101)
- ✅ Ollama (Port 8021)

### Optional: YouTube API Key

**Kostenlos erhältlich:**
1. Gehe zu [Google Cloud Console](https://console.cloud.google.com)
2. Erstelle neues Projekt
3. Aktiviere "YouTube Data API v3"
4. Erstelle API-Credentials
5. Kopiere API Key

**Hinweis:** Ohne API Key funktioniert YouTube RSS Feed immer noch (kostenlos, 50 Videos pro Channel)!

---

## 🚀 Installation

### Schritt 1: n8n Tables erstellen

#### Table 1: youtube_channels

1. Öffne n8n: `http://192.168.178.151:8000`
2. Gehe zu **Workflows** → **Tables**
3. Klicke **"Create New Table"**
4. Name: `youtube_channels`
5. Füge Spalten hinzu aus `tables/youtube_channels.json`:

| Spalte | Typ | Required |
|--------|-----|----------|
| channel_id | Text | ✅ (Unique) |
| channel_name | Text | ✅ |
| channel_url | Text | ✅ |
| original_language | Text | ✅ |
| enabled | Boolean | ✅ (Default: true) |
| notebook_name | Text | ✅ |
| notebook_id | Text | ❌ |
| last_sync | DateTime | ❌ |
| video_count | Number | ❌ (Default: 0) |
| created_at | DateTime | ❌ (Auto) |

6. **Speichern**

#### Table 2: youtube_videos

1. Klicke **"Create New Table"**
2. Name: `youtube_videos`
3. Füge Spalten hinzu aus `tables/youtube_videos.json`:

| Spalte | Typ | Required |
|--------|-----|----------|
| video_id | Text | ✅ (Unique) |
| channel_id | Text | ✅ |
| title | Text | ✅ |
| url | Text | ✅ |
| duration_seconds | Number | ✅ |
| published_date | DateTime | ✅ |
| thumbnail_url | Text | ❌ |
| detected_language | Text | ❌ |
| needs_translation | Boolean | ❌ |
| status | Select | ✅ (siehe Optionen unten) |
| skip_reason | Text | ❌ |
| notebook_entry_url | Text | ❌ |
| discovered_at | DateTime | ✅ (Auto) |
| processed_at | DateTime | ❌ |
| error_message | Text | ❌ |

**Status Optionen:**
- `discovered`
- `transcribing`
- `translating`
- `summarizing`
- `podcast_generating`
- `completed`
- `failed`
- `skipped`

4. **Speichern**

### Schritt 2: Workflow importieren

1. In n8n: Klicke **"+ Add Workflow"**
2. Menü (⋮) → **"Import from File"**
3. Wähle: `workflows/01-youtube-channel-sync.json`
4. **Import**
5. Workflow wird geöffnet

### Schritt 3: Workflow konfigurieren

**Wichtig zu prüfen:**

1. **Schedule Trigger Node:**
   - Zeit: 06:00 (anpassen wenn gewünscht)
   - Timezone: Europe/Berlin

2. **HTTP Request Nodes:**
   - Alle Service-URLs sollten korrekt sein:
     - `http://faster-whisper:8000` ✅
     - `http://libretranslate:5000` ✅
     - `http://ollama:11434` ✅
     - `http://openedai-speech:8000` ✅
     - `http://open-notebook:5055` ✅

3. **Optional: YouTube API Key:**
   - Falls vorhanden, trage in HTTP Request Node ein

4. **Speichern** (STRG+S)

### Schritt 4: Test-Channel hinzufügen

1. Gehe zu **Tables** → **youtube_channels**
2. Klicke **"Add Row"**
3. Füge Test-Daten ein:

```
channel_id: UCXuqSBlHAE6Xw-yeJA0Tunw
channel_name: Linus Tech Tips
channel_url: youtube.com/@LinusTechTips
original_language: en
enabled: true
notebook_name: YT: Linus Tech Tips
```

4. **Speichern**

### Schritt 5: Ersten Test durchführen

1. Öffne den Workflow
2. Klicke **"Execute Workflow"** (oben rechts)
3. **Beobachte:**
   - Logs im Execution Panel
   - n8n Table `youtube_videos` füllt sich
   - Open Notebook (Port 8100) zeigt neue Einträge

4. **Validierung:**
   - Öffne Open Notebook: `http://192.168.178.151:8100`
   - Prüfe ob Notebook "YT: Linus Tech Tips" existiert
   - Prüfe Video-Einträge
   - Teste Podcast-Audio

---

## 🎛️ Konfiguration

### Channel hinzufügen

**In n8n Table `youtube_channels`:**

| Feld | Wert | Beispiel |
|------|------|----------|
| channel_id | YouTube Channel ID | `UCXuqSBlHAE6Xw-yeJA0Tunw` |
| channel_name | Dein Name | `Linus Tech Tips` |
| channel_url | YouTube URL | `youtube.com/@LinusTechTips` |
| original_language | ISO Code | `en` (Englisch), `de` (Deutsch), `es` (Spanisch) |
| enabled | true/false | `true` |
| notebook_name | Anzeigename | `YT: Linus Tech Tips` |

**Channel ID finden:**
1. Öffne YouTube-Kanal
2. Klicke "Teilen" → "Kanal-Link kopieren"
3. URL: `youtube.com/channel/UCXuqSBlHAE6Xw-yeJA0Tunw`
4. Channel ID: `UCXuqSBlHAE6Xw-yeJA0Tunw`

### Workflow anpassen

**Datei:** `config/workflow_config.json`

```json
{
  "filtering": {
    "min_duration_seconds": 300,    // Mindestens 5 Minuten
    "max_duration_seconds": 7200,   // Maximal 2 Stunden
    "exclude_shorts": true           // Shorts ausschließen (<60s)
  },
  
  "processing": {
    "batch_size": 5,                 // 5 Videos parallel
    "wait_between_batches": 10,      // 10 Sekunden Pause
    "max_videos_per_run": 50         // Max 50 Videos pro Tag
  },
  
  "summary": {
    "length_words": 300,             // 300 Wörter Summary
    "language": "de",                // Immer deutsch
    "style": "professional"          // Professional Tone
  },
  
  "podcast": {
    "voice": "thorsten",             // Deutsche Thorsten Voice
    "speed": 1.0                     // Normale Geschwindigkeit
  }
}
```

---

## 🔧 Troubleshooting

### Problem: Keine neuen Videos gefunden

**Lösung:**
```bash
# Prüfe ob Channel aktiv ist
docker exec postgres psql -U postgres -d n8n -c "SELECT * FROM youtube_channels WHERE enabled=true;"

# Prüfe YouTube RSS Feed manuell
curl "https://www.youtube.com/feeds/videos.xml?channel_id=UCXuqSBlHAE6Xw-yeJA0Tunw"
```

### Problem: Whisper Transkription schlägt fehl

**Lösung:**
```bash
# Prüfe Whisper Service
docker logs faster-whisper --tail 50

# Test manuell
curl -X POST http://localhost:8080/v1/audio/transcriptions \
  -H "Content-Type: application/json" \
  -d '{"url":"https://youtube.com/watch?v=dQw4w9WgXcQ"}'
```

### Problem: Translation funktioniert nicht

**Lösung:**
```bash
# Prüfe LibreTranslate
docker logs libretranslate --tail 50

# Test manuell
curl -X POST http://localhost:8082/translate \
  -H "Content-Type: application/json" \
  -d '{"q":"Hello World","source":"en","target":"de"}'
```

### Problem: Open Notebook API Fehler

**Lösung:**
```bash
# Prüfe Open Notebook
docker logs open-notebook --tail 50

# Test API
curl http://localhost:8101/api/health
```

### Problem: Workflow hängt

**Häufigste Ursachen:**
1. **Whisper Processing** - Videos >1h dauern lange
2. **Ollama Overload** - Nur 1 Request gleichzeitig möglich
3. **LibreTranslate** - Große Texte (>10k Zeichen) dauern

**Lösung:** Reduziere `batch_size` auf 2-3

---

## 📊 Monitoring

### Status prüfen

**In n8n:**
```
1. Öffne Workflow
2. Klicke "Executions" (oben)
3. Sieh alle Durchläufe mit Status
```

**In n8n Tables:**
```sql
-- Anzahl Videos pro Status
SELECT status, COUNT(*) 
FROM youtube_videos 
GROUP BY status;

-- Letzte verarbeitete Videos
SELECT video_id, title, status, processed_at
FROM youtube_videos
WHERE status = 'completed'
ORDER BY processed_at DESC
LIMIT 10;

-- Fehler auflisten
SELECT video_id, title, error_message
FROM youtube_videos
WHERE status = 'failed';
```

### Performance-Metriken

**Durchschnittliche Verarbeitungszeit:**
- 10 Min Video: ~3 Minuten
- 30 Min Video: ~10 Minuten
- 60 Min Video: ~20 Minuten

**Tägliche Kapazität:**
- Empfohlen: 50 Videos/Tag
- Maximum: 250 Videos/Tag (mit Batch-Processing)

---

## 🎨 Open Notebook Struktur

Nach der Verarbeitung siehst du in Open Notebook:

```
📁 YouTube Channels/
  │
  ├─ 📁 YT: Linus Tech Tips/
  │   ├─ 📄 2025-11-07 - Video Title 1.md
  │   │   ├─ Management Summary (Deutsch)
  │   │   ├─ Transkript (Deutsch)
  │   │   └─ 🎧 Podcast-Link
  │   │
  │   ├─ 📄 2025-11-08 - Video Title 2.md
  │   └─ ...
  │
  └─ 📁 YT: [Weitere Channels]/
```

**Jeder Eintrag enthält:**
- Metadaten (Titel, Datum, Dauer, Sprache)
- Deutsche Management Summary (~300 Wörter)
- Vollständiges deutsches Transkript
- Link zum Podcast (MP3, Thorsten Voice)

---

## 🔄 Workflow aktivieren/deaktivieren

### Schedule aktivieren

1. Öffne Workflow
2. Klicke auf **Schedule Trigger** Node
3. Toggle **"Active"** auf ON
4. **Speichern**

**Workflow läuft jetzt täglich um 6:00 Uhr!**

### Schedule deaktivieren

1. Öffne Workflow
2. Toggle **"Active"** auf OFF
3. **Speichern**

---

## 📈 Skalierung

### Mehrere Channels hinzufügen

**So viele wie du willst!**

```
In Table youtube_channels:
- Füge neue Rows hinzu
- Setze enabled=true
- Workflow verarbeitet ALLE aktiven Channels
```

**Empfohlene Limits:**
- Start: 2-3 Channels (zum Testen)
- Klein: 5-10 Channels (~50 Videos/Tag)
- Mittel: 20-30 Channels (~200 Videos/Tag)
- Groß: 50+ Channels (benötigt GPU für Whisper!)

### Performance-Optimierung

**Für >100 Videos/Tag:**

1. **Erhöhe batch_size:**
   ```
   Von 5 → 10 (wenn genug RAM)
   ```

2. **GPU für Whisper aktivieren:**
   ```bash
   # In .env auf Server
   COMPOSE_PROFILES="...,speech-gpu"
   ```

3. **Workflow-Zeitplan anpassen:**
   ```
   Statt 1x täglich → 2x täglich (6:00 + 18:00)
   ```

---

## 🛠️ Wartung

### Alte Videos aufräumen

```sql
-- Videos älter als 90 Tage löschen
DELETE FROM youtube_videos
WHERE discovered_at < NOW() - INTERVAL '90 days'
AND status IN ('completed', 'skipped', 'failed');
```

### Fehlgeschlagene Videos erneut versuchen

```sql
-- Status zurücksetzen
UPDATE youtube_videos
SET status = 'discovered',
    error_message = NULL
WHERE status = 'failed'
AND discovered_at > NOW() - INTERVAL '7 days';
```

### Channel deaktivieren (temporär)

```sql
-- Channel pausieren
UPDATE youtube_channels
SET enabled = false
WHERE channel_id = 'UCXuqSBlHAE6Xw-yeJA0Tunw';
```

---

## 🎯 Nächste Schritte nach Installation

1. **Ersten Channel hinzufügen** (siehe oben)
2. **Workflow manuell testen** (Execute Workflow)
3. **Logs prüfen** (sollte 1-5 Videos verarbeiten)
4. **Open Notebook checken** (neue Einträge sichtbar?)
5. **Schedule aktivieren** (für tägliche Runs)
6. **Weitere Channels hinzufügen**
7. **Nach 1 Woche:** Performance reviewen

---

## 💡 Tipps & Best Practices

### Channel-Auswahl

**Gut geeignet:**
- ✅ Regelmäßige Uploads (täglich/wöchentlich)
- ✅ Mittlere Video-Länge (10-30 Min)
- ✅ Keine Livestreams
- ✅ Klare Audio-Qualität

**Weniger geeignet:**
- ❌ Musik-Channels (Transkript meist unnötig)
- ❌ Sehr lange Videos (>2h)
- ❌ Viele Shorts
- ❌ Livestream-Channels

### Sprach-Kombinationen

**Funktioniert perfekt:**
- Englisch → Deutsch (sehr gut)
- Spanisch → Deutsch (gut)
- Französisch → Deutsch (gut)

**Funktioniert OK:**
- Italienisch, Portugiesisch, Russisch

**Nicht unterstützt:**
- Asiatische Sprachen (noch nicht in LibreTranslate)

---

## 📞 Support

### Logs anschauen

**n8n Workflow Logs:**
```
1. Öffne Workflow
2. Klicke "Executions"
3. Wähle fehlgeschlagene Execution
4. Sieh welcher Node fehlgeschlagen ist
```

**Service Logs:**
```bash
# Auf dem Server
docker logs faster-whisper --tail 100
docker logs libretranslate --tail 100
docker logs open-notebook --tail 100
```

### Häufige Probleme

| Problem | Ursache | Lösung |
|---------|---------|--------|
| "Table not found" | Tables nicht erstellt | Siehe Schritt 1 |
| "Service unreachable" | Service nicht gestartet | `docker ps` prüfen |
| "Out of memory" | Zu viele parallele Videos | Reduziere batch_size |
| "Translation failed" | Sprache nicht unterstützt | Original-Text verwenden |

---

## 🎉 Fertig!

Du hast jetzt ein vollautomatisches System das:
- ✅ YouTube-Kanäle überwacht
- ✅ Videos transkribiert
- ✅ Zu Deutsch übersetzt
- ✅ Summaries erstellt
- ✅ Podcasts generiert
- ✅ Alles strukturiert ablegt

**Komplett kostenlos und lokal!**

---

**Projekt:** YouTube to Open Notebook
**Version:** 1.0.0
**Erstellt:** 8.11.2025
**Autor:** AI LaunchKit Community
