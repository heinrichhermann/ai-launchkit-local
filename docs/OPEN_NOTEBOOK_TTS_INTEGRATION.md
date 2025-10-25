# Open Notebook - Lokale Speech Services Integration (STT + TTS)

> **📍 Hinweis zur SERVER_IP:** 
> `${SERVER_IP}` ist eine Variable, die während der Installation automatisch erkannt 
> oder manuell konfiguriert wird. Sie finden den Wert in Ihrer `.env` Datei.
> 
> **Beispiel:** Wenn Ihr Ubuntu Server die IP `192.168.1.50` hat, dann wäre der 
> Zugriff: `http://192.168.1.50:8100`

> **📚 Siehe auch: Umfassende Anleitung**
> 
> Für detaillierte Use Cases, Deutsche Podcasts, YouTube Transkription und mehr:
> **[Open Notebook - Umfassende Anleitung & Use Cases](OPEN_NOTEBOOK_GUIDE.md)**

## 🎯 Übersicht

Diese Anleitung zeigt dir, wie du die **lokalen Speech-Services** des AI LaunchKit mit Open Notebook nutzt:
- **STT (Speech-to-Text):** Faster Whisper für Audio-Transkription
- **TTS (Text-to-Speech):** OpenedAI Speech für Podcast-Generierung

Beide Services sind **komplett kostenlos** und laufen lokal auf deinem Server! 🎉

## ✅ Voraussetzungen

1. **Speech Services aktiviert:** Das `speech` Profil muss aktiv sein
2. **Services laufen:**
   ```bash
   # Prüfe ob Services laufen:
   curl http://${SERVER_IP}:8080/health  # Faster Whisper (STT)
   curl http://${SERVER_IP}:8081/health  # OpenedAI Speech (TTS)
   ```
3. **docker-compose.local.yml korrekt konfiguriert** (siehe unten)

## 📋 Konfiguration

### Schritt 1: Environment-Variablen in docker-compose.local.yml

Die docker-compose.local.yml wurde korrigiert und enthält **beide** Speech-Services:

```yaml
open-notebook:
  environment:
    # Für Speech-to-Text (Audio/Video-Transkription)
    - OPENAI_COMPATIBLE_BASE_URL_STT=http://faster-whisper:8000/v1
    
    # Für Text-to-Speech (Podcast-Audio-Generierung)
    - OPENAI_COMPATIBLE_BASE_URL_TTS=http://openedai-speech:8000/v1
```

**⚠️ WICHTIG:** 
- Variablen heißen `OPENAI_COMPATIBLE_BASE_URL_STT` und `OPENAI_COMPATIBLE_BASE_URL_TTS`
- **NICHT** `WHISPER_API_BASE` oder `OPENAI_SPEECH_API_BASE`
- Pfade enden mit `/v1` (OpenAI API Standard)

### Schritt 2: Container neu starten

**Auf dem Ubuntu Server:**

```bash
cd ~/ai-launchkit-local && sudo docker rm -f open-notebook && sudo docker compose -f docker-compose.local.yml up -d open-notebook && sleep 15 && echo "=== Verifiziere Environment-Variable ===" && docker exec open-notebook env | grep OPENAI_COMPATIBLE_BASE_URL_TTS
```

**Erwartete Ausgabe:**
```
=== Verifiziere Environment-Variable ===
OPENAI_COMPATIBLE_BASE_URL_TTS=http://openedai-speech:8000/v1
```

### Schritt 3: TTS Model in Open Notebook UI hinzufügen

**WICHTIG:** Du konfigurierst **NICHT den Provider**, sondern fügst ein **Model** hinzu!

1. **Öffne:** `http://${SERVER_IP}:8100`
2. **Gehe zu:** Settings (⚙️) → **Models**
3. **Im "Text-to-Speech" Bereich:** Klicke **"+ Add Model"**
4. **Konfiguriere das Model:**
   ```
   Provider: openai_compatible (aus Dropdown wählen)
   Model Name: tts-1
   Display Name: Local OpenedAI TTS
   ```
5. **Speichern**

**⚠️ KEINE Base URL eingeben!** Die Base URL kommt automatisch aus der Environment-Variable `OPENAI_COMPATIBLE_BASE_URL_TTS`.

### Schritt 4: STT Model in Open Notebook UI hinzufügen

Für **Speech-to-Text** (Audio-Transkription):

1. **Öffne:** `http://${SERVER_IP}:8100`
2. **Gehe zu:** Settings (⚙️) → **Models**
3. **Im "Speech-to-Text" Bereich:** Klicke **"+ Add Model"**
4. **Konfiguriere das Model:**
   ```
   Provider: openai_compatible (aus Dropdown wählen)
   Model Name: whisper-1
   Display Name: Local Whisper STT
   ```
5. **Speichern**

**⚠️ Auch hier:** KEINE Base URL eingeben! Die kommt aus `OPENAI_COMPATIBLE_BASE_URL_STT`.

### Schritt 5: Optional - Models als Default setzen

In Settings → Models kannst du die lokalen Models als Standard setzen:
- **TTS:** "Local OpenedAI TTS" als Standard TTS Model
- **STT:** "Local Whisper STT" als Standard STT Model

## 🎙️ Podcast mit lokalem TTS generieren

### Episode Profile erstellen

1. **Gehe zu:** Podcasts → Episode Profiles → **"+ New Profile"**
2. **Konfiguriere:**
   ```
   Name: Deutsches Podcast-Profil
   Number of Speakers: 1 oder 2
   ```

3. **Speaker konfigurieren:**

   **Für deutsche Podcasts (empfohlen):**
   ```
   Speaker 1:
   - Name: Moderator
   - TTS Model: Local OpenedAI TTS
   - Voice: thorsten
   - Role: "Professional German podcast host"
   ```
   
   **Für englische Podcasts:**
   ```
   Speaker 1 (Host):
   - Name: Host
   - TTS Model: Local OpenedAI TTS
   - Voice: alloy
   - Role: "Professional host, asks engaging questions"
   
   Speaker 2 (Expert):
   - Name: Expert
   - TTS Model: Local OpenedAI TTS
   - Voice: nova
   - Role: "Subject matter expert, provides detailed answers"
   ```

### Verfügbare Stimmen

**Englische Stimmen (OpenAI-kompatibel):**
- **alloy** - Neutral, ausgewogen
- **echo** - Männlich, warm
- **fable** - Männlich, kräftig
- **onyx** - Männlich, tief
- **nova** - Weiblich, freundlich
- **shimmer** - Weiblich, weich

**Deutsche Stimmen:**
- **thorsten** - Männlich, High Quality (22.05kHz)
  - Native deutsche Aussprache
  - Professionelle Qualität für Podcasts
  - Automatisch installiert bei Speech Services
  - Quelle: Piper TTS (Thorsten Voice)

### Podcast generieren

1. **Öffne ein Notebook** mit Quellen
2. **Klicke:** "Generate Podcast"
3. **Wähle:** Quellen aus
4. **Wähle:** Dein Episode Profile
5. **Generate**

**Die Audio-Generierung erfolgt jetzt komplett lokal und kostenlos!** 🎉

### Sprachauswahl

**Für deutsche Inhalte:**
- Verwende Voice: `thorsten`
- Spricht native deutschen Text
- Englische Fachwörter werden phonetisch ausgesprochen

**Für englische Inhalte:**
- Verwende Voice: `alloy`, `nova`, `echo`, etc.
- Optimiert für englische Aussprache

**Hinweis:** Thorsten ist ein monolinguales deutsches Modell. Englische Wörter (z.B. "App", "Framework") werden mit deutscher Phonetik ausgesprochen. Für gemischte Inhalte mit vielen englischen Fachbegriffen empfehlen wir XTTS-v2 mit custom Sample (fortgeschrittenes Setup).

## 🎧 Audio-Transkription mit lokalem STT

### Audio/Video-Dateien transkribieren

1. **Öffne ein Notebook**
2. **Add Source** → **Upload File**
3. **Wähle Audio oder Video-Datei** (MP3, WAV, MP4, etc.)
4. Open Notebook nutzt automatisch **Local Whisper STT** für die Transkription
5. **Ergebnis:** Text wird extrahiert und durchsuchbar gemacht

### Verfügbare Formate

Faster Whisper unterstützt:
- **Audio:** MP3, WAV, M4A, FLAC, OGG
- **Video:** MP4, MKV, AVI, MOV (extrahiert Audio)

### Verwendung

**Automatische Transkription bei:**
- Upload von Audio/Video-Dateien
- Verarbeitung von YouTube-Videos
- Podcast-Analyse

**Vorteile:**
- ✅ Komplett offline
- ✅ Keine API-Kosten
- ✅ Unbegrenzte Nutzung
- ✅ Schnelle Verarbeitung (CPU-optimiert)

## � Verifizierung

### Prüfe ob lokaler TTS genutzt wird

Während der Podcast generiert wird:

```bash
# Logs von Open Notebook
docker logs -f open-notebook

# Logs von OpenedAI TTS (sollte Aktivität zeigen!)
docker logs -f openedai-speech
```

**Du solltest sehen:**
- Open Notebook macht Requests an `openedai-speech:8000/v1/audio/speech`
- OpenedAI Speech generiert Audio-Segmente
- **Keine externen API-Calls** zu OpenAI TTS (keine Kosten!)

### Test-Befehl

Test die TTS API direkt:

```bash
docker exec open-notebook curl -s http://openedai-speech:8000/v1/models
```

Sollte eine Liste von verfügbaren Modellen zurückgeben.

## �📍 Wo finde ich den generierten Podcast?

### In der UI

1. **Gehe zu:** Podcasts Seite (Menü links)
2. **Dein Podcast** sollte dort aufgelistet sein
3. **Klicke darauf** → **Play-Button (▶️)** erscheint
4. **Oder Download-Button (📥)** nutzen

### Auf dem Filesystem

```bash
# Auf dem Server:
cd ~/ai-launchkit-local/open-notebook/data

# Suche nach generierten Audio-Dateien:
find . -name "*.mp3" -o -name "*.wav" -o -name "*.opus"

# Wahrscheinlich in:
ls -lah podcasts/episodes/
```

### Via API

```bash
# Liste alle Podcasts auf:
curl http://${SERVER_IP}:8101/api/podcasts

# API Dokumentation:
http://${SERVER_IP}:8101/docs
```

## 💰 Kosten-Vergleich

| Komponente | Cloud (OpenAI) | Lokal (AI LaunchKit) |
|------------|----------------|----------------------|
| **Script-Generierung (LLM)** | $0.01-0.03 per 1K tokens | Kostenlos mit Ollama |
| **Audio-Generierung (TTS)** | $15 per 1M Zeichen | **Kostenlos** ✅ |
| **Gesamt für 10-Min Podcast** | $2-5 | **$0** ✅ |
| **Deutsche Stimme** | Nicht verfügbar | **Thorsten inkludiert** ✅ |

## 🚨 Troubleshooting

### "Not configured" in der UI

**Problem:** Provider zeigt "Not configured" an

**Lösung:**
1. Stelle sicher, dass die Environment-Variable gesetzt ist:
   ```bash
   docker exec open-notebook env | grep OPENAI_COMPATIBLE_BASE_URL_TTS
   ```
2. Container muss mit der neuen Variable neu gestartet worden sein
3. In UI: Model hinzufügen (provider: openai_compatible, model: tts-1)

### TTS funktioniert nicht

**Prüfe:**
```bash
# 1. Service läuft?
curl http://localhost:8081/health

# 2. Container kann Service erreichen?
docker exec open-notebook curl -s http://openedai-speech:8000/health

# 3. Environment-Variable richtig gesetzt?
docker exec open-notebook env | grep OPENAI_COMPATIBLE_BASE_URL_TTS
```

### Kein Audio in generiertem Podcast

**Mögliche Ursachen:**
1. TTS Model nicht ausgewählt im Episode Profile
2. Service nicht erreichbar
3. Voice-Name falsch geschrieben (case-sensitive!)

**Debug:**
```bash
docker logs open-notebook | grep -i tts
docker logs openedai-speech | tail -50
```

## 🎓 Best Practices

### 1. Multi-Speaker Setup

Nutze verschiedene Stimmen für natürlichere Gespräche:

```
Host: alloy oder nova (freundlich)
Expert: onyx oder echo (autoritativ)
Narrator: shimmer oder fable (neutral)
```

### 2. Episode Profile Templates

Erstelle verschiedene Profile für verschiedene Podcast-Typen:

**Interview-Style:**
- 2 Speaker: alloy (Host) + nova (Guest)
- Professional und zugänglich

**Panel-Discussion:**
- 3 Speaker: alloy (Moderator) + echo (Expert 1) + nova (Expert 2)
- Verschiedene Perspektiven

**Solo-Präsentation:**
- 1 Speaker: fable oder onyx
- Authoritative Stimme

### 3. Performance-Optimierung

**Für schnellere Generierung:**
- Nutze kürzere Quellen-Texte
- Wähle `tts-1` statt `tts-1-hd` (schneller, aber leicht niedrigere Qualität)
- Stelle sicher, dass der Server genug CPU hat

## 🔗 Weiterführende Links

- [Open Notebook Local TTS Guide](https://github.com/lfnovo/open-notebook/blob/main/docs/features/local_tts.md)
- [OpenAI-Compatible Setup](https://github.com/lfnovo/open-notebook/blob/main/docs/features/openai-compatible.md)
- [OpenedAI Speech Projekt](https://github.com/matatonic/openedai-speech)

## 📝 Zusammenfassung

**Environment-Variable richtig setzen:**
```yaml
OPENAI_COMPATIBLE_BASE_URL_TTS=http://openedai-speech:8000/v1
```

**In UI nur Model hinzufügen:**
- Provider: openai_compatible
- Model: tts-1
- **KEINE Base URL eingeben!**

**Bei Podcast-Generierung:**
- Model auswählen
- Stimme wählen (alloy, echo, fable, onyx, nova, shimmer)
- Generieren → Komplett kostenlos! 🎉
