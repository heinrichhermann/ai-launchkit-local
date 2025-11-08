# YouTube to Open Notebook - Schnellstart (5 Minuten)

## ⚡ Automatisches Setup (Empfohlen!)

**Du musst KEINE Spalten manuell anlegen!**

### Methode A: SQL-Script (1 Befehl) 🚀

**Auf dem Server:**

```bash
# 1. Updates holen
cd ~/ai/ai-launchkit-local
git pull origin main

# 2. SQL-Script ausführen (erstellt beide Tables automatisch)
cat n8n_custom_workflows/youtube-open-notebook/setup/create_tables.sql | \
  docker exec -i postgres psql -U postgres -d postgres

# 3. Verifiziere
docker exec postgres psql -U postgres -d postgres -c "
  SELECT table_name 
  FROM information_schema.tables 
  WHERE table_name IN ('youtube_channels', 'youtube_videos');"
```

**Erwartete Ausgabe:**
```
    table_name     
-------------------
 youtube_channels
 youtube_videos
(2 rows)

✅ Tables erstellt!
✅ 2 Beispiel-Channels eingefügt!
```

**Das war's!** Keine manuelle Spalten-Erstellung nötig!

---

### Methode B: Copy-Paste in n8n UI (10 Minuten)

**Falls du die UI bevorzugst:**

1. Öffne n8n: `http://192.168.178.151:8000`
2. Gehe zu **Workflows** → **Tables**
3. Klicke **"Create New Table"**

#### Table 1: youtube_channels (10 Spalten)

| Spalte | Typ | Einstellungen |
|--------|-----|---------------|
| channel_id | Text | ✅ Required, ✅ Unique |
| channel_name | Text | ✅ Required |
| channel_url | Text | ✅ Required |
| original_language | Text | ✅ Required |
| enabled | Boolean | ✅ Required, Default: true |
| notebook_name | Text | ✅ Required |
| notebook_id | Text | ❌ Optional |
| last_sync | DateTime | ❌ Optional |
| video_count | Number | ❌ Optional, Default: 0 |
| created_at | DateTime | ❌ Auto-create |

#### Table 2: youtube_videos (15 Spalten)

| Spalte | Typ | Einstellungen |
|--------|-----|---------------|
| video_id | Text | ✅ Required, ✅ Unique |
| channel_id | Text | ✅ Required |
| title | Text | ✅ Required |
| url | Text | ✅ Required |
| duration_seconds | Number | ✅ Required |
| published_date | DateTime | ✅ Required |
| thumbnail_url | Text | ❌ Optional |
| detected_language | Text | ❌ Optional |
| needs_translation | Boolean | ❌ Optional |
| status | Select | ✅ Required, Default: "discovered" |
| skip_reason | Text | ❌ Optional |
| notebook_entry_url | Text | ❌ Optional |
| discovered_at | DateTime | ✅ Auto-create |
| processed_at | DateTime | ❌ Optional |
| error_message | Text | ❌ Optional |

**Status Select-Optionen:**
`discovered`, `transcribing`, `translating`, `summarizing`, `podcast_generating`, `completed`, `failed`, `skipped`

---

## 🚀 Workflow Installation

### Schritt 1: PostgreSQL Credentials in n8n erstellen

**Wichtig:** Der Workflow benötigt PostgreSQL Credentials!

**In n8n Web UI:**
1. Gehe zu **Settings** → **Credentials** → **Add Credential**
2. Wähle **"Postgres"**
3. Konfiguriere:
   ```
   Name: AI LaunchKit PostgreSQL
   Host: postgres
   Database: postgres
   User: postgres
   Password: [Dein POSTGRES_PASSWORD aus .env]
   Port: 5432
   SSL: Disabled
   ```
4. **Test Connection** klicken
5. **Save** klicken

**Hinweis:** Passwort findest du in deiner `.env` Datei:
```bash
grep POSTGRES_PASSWORD ~/ai/ai-launchkit-local/.env
```

### Schritt 2: Workflow importieren

```bash
# Tables sollten bereits existieren (via SQL-Script oben)

# In n8n Web UI:
# 1. Klicke "+ Add Workflow"
# 2. Menü → "Import from File"  
# 3. Wähle: n8n_custom_workflows/youtube-open-notebook/workflows/01-youtube-channel-sync-mvp.json
# 4. Workflow öffnet sich
```

### Schritt 2: Ersten Test ausführen

```bash
# 1. Im Workflow: Klicke "Execute Workflow"
# 2. Beobachte Logs
# 3. Prüfe Table youtube_videos
# 4. Öffne Open Notebook: http://192.168.178.151:8100
```

**Das war's! Workflow läuft!** ✅

---

## 🎯 Kompletter 5-Minuten-Setup

```bash
# Auf dem Server (192.168.178.151)

# 1. Updates holen (30 Sekunden)
cd ~/ai/ai-launchkit-local
git pull origin main

# 2. PostgreSQL Settings anpassen (1 Minute)
nano .env
# Füge hinzu:
# POSTGRES_MAX_CONNECTIONS=500
# POSTGRES_SHARED_BUFFERS=24GB
# POSTGRES_EFFECTIVE_CACHE_SIZE=72GB
# POSTGRES_WORK_MEM=256MB
# POSTGRES_MAX_WORKER_PROCESSES=16
# N8N_WORKER_COUNT=8

# 3. Stack neu starten (2 Minuten)
docker compose -p localai -f docker-compose.local.yml down
docker compose -p localai -f docker-compose.local.yml up -d
sleep 30

# 4. Tables erstellen (10 Sekunden)
cat n8n_custom_workflows/youtube-open-notebook/setup/create_tables.sql | \
  docker exec -i postgres psql -U postgres -d postgres

# 5. Workflow importieren (1 Minute)
# → In n8n UI: Import workflows/01-youtube-channel-sync-mvp.json

# 6. Test ausführen (30 Sekunden)
# → In n8n UI: Execute Workflow

# ✅ FERTIG! (Total: ~5 Minuten)
```

---

## 📋 Checkliste

- [ ] Git pull ausgeführt
- [ ] .env angepasst (PostgreSQL Settings)
- [ ] Stack neu gestartet
- [ ] SQL-Script ausgeführt (Tables erstellt)
- [ ] Workflow importiert
- [ ] Ersten Test durchgeführt
- [ ] Open Notebook geprüft (Port 8100)

---

## 🔧 Troubleshooting

### Problem: SQL-Script Fehler

```bash
# Hinweis: n8n nutzt die 'postgres' Datenbank in AI LaunchKit
# Prüfe ob Tables bereits existieren
docker exec postgres psql -U postgres -d postgres -c "\dt"
```

### Problem: Tables existieren bereits

```bash
# Löschen und neu erstellen
docker exec postgres psql -U postgres -d postgres -c "
  DROP TABLE IF EXISTS youtube_videos CASCADE;
  DROP TABLE IF EXISTS youtube_channels CASCADE;"

# Dann SQL-Script erneut ausführen
```

### Problem: Workflow findet Tables nicht

```bash
# Prüfe Tabellen-Namen
docker exec postgres psql -U postgres -d postgres -c "\dt"

# Sollte zeigen:
#  youtube_channels
#  youtube_videos
```

---

## 💡 Zusatz-Features (Optional)

### Channel hinzufügen (via SQL)

```bash
docker exec postgres psql -U postgres -d postgres -c "
INSERT INTO youtube_channels (
  channel_id, 
  channel_name, 
  channel_url, 
  original_language, 
  enabled, 
  notebook_name
) VALUES (
  'DEINE_CHANNEL_ID',
  'Kanal Name',
  'youtube.com/@username',
  'en',
  true,
  'YT: Kanal Name'
);"
```

### Status aller Videos anzeigen

```bash
docker exec postgres psql -U postgres -d postgres -c "
SELECT status, count(*) 
FROM youtube_videos 
GROUP BY status;"
```

### Fehlgeschlagene Videos auflisten

```bash
docker exec postgres psql -U postgres -d postgres -c "
SELECT video_id, title, error_message 
FROM youtube_videos 
WHERE status = 'failed';"
```

---

## 🎉 Fertig!

**Mit dem SQL-Script:**
- ✅ Keine manuelle Spalten-Erstellung
- ✅ 1 Befehl, alles fertig
- ✅ 2 Beispiel-Channels bereits drin
- ✅ Indexes automatisch erstellt

**Workflow ist produktionsbereit!** 🚀

---

**Erstellt:** 8.11.2025
**Autor:** AI LaunchKit Community
**Support:** docs/README.md
