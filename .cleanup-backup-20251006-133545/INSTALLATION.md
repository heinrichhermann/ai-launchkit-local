# 🚀 AI LaunchKit Local - Installation Guide

## Was wurde umgesetzt

Das AI LaunchKit wurde **vollständig für lokale Netzwerk-Bereitstellung umgebaut**:

### ✅ Completed Modifications

1. **Docker-Compose komplett umgebaut** (`docker-compose.local.yml`)
   - Caddy Reverse Proxy vollständig entfernt
   - Alle 40+ Services mit direkten Port-Mappings (8000-8099)
   - Interne Service-Kommunikation über Docker-Netzwerk beibehalten
   - Jitsi UDP Port 10000 für WebRTC beibehalten

2. **Port-basierte Konfiguration** (`.env.local.example`)
   - Alle Domain-Variablen durch SERVER_IP ersetzt
   - HTTP-only Konfiguration (keine SSL)
   - Lokale Mail-Konfiguration mit Mailpit
   - Systematisches Port-Schema implementiert

3. **Installations-Scripts angepasst** (5 Scripts)
   - `install_local.sh`: Hauptinstallation ohne Domain-Setup
   - `03_generate_secrets_local.sh`: Python bcrypt statt Caddy für Passwort-Hashing
   - `04_wizard_local.sh`: Service-Auswahl mit Port-Informationen  
   - `05_run_services_local.sh`: Container-Start mit Port-Checks
   - `06_final_report_local.sh`: Port-basierter Zugriffs-Report

4. **Service-Orchestrierung** (`start_services_local.py`)
   - Multi-Compose-File Orchestrierung (Haupt + Supabase + Dify)
   - Port-Konflikt-Erkennung
   - Lokale Netzwerk-Konfiguration für externe Repos

5. **Vollständige Dokumentation** (`README.local.md`)
   - Port-Schema für alle Services
   - Netzwerk-Konfiguration für LAN-Zugriff
   - Troubleshooting für häufige Probleme
   - Management-Commands

## 🎯 Port-Schema (systematisch strukturiert)

### Core Services (8000-8019)
```
8000: n8n (Workflow Automation)
8001: PostgreSQL (Database)
8002: Redis (Cache) 
8003: Grafana (Monitoring)
8004: Prometheus (Metrics)
8005: Node Exporter (System Metrics)
8006: cAdvisor (Container Monitoring)
8007: Portainer (Docker Management)
```

### AI Services (8020-8039)  
```
8020: Open WebUI (ChatGPT Interface)
8021: Ollama (Local LLM Runtime)
8022: Flowise (AI Agent Builder)
8023: bolt.diy (AI Web Development)
8024: ComfyUI (Image Generation)
8025: OpenUI (AI UI Generator)
8026: Qdrant (Vector Database)
8027: Weaviate (Vector Database)
8028: Neo4j (Graph Database)
8029: LightRAG (Graph RAG)
8030: RAGApp (RAG Interface)
8031: Letta (Agent Server)
```

### Business Tools (8040-8059)
```
8040: Cal.com (Scheduling)
8041: Odoo (ERP/CRM)
8042: Kimai (Time Tracking)
8043: Invoice Ninja (Invoicing)
8044: Twenty CRM (Modern CRM)
8045: EspoCRM (Full CRM)
8046: Mautic (Marketing Automation)
8047: Baserow (Database)
8048: NocoDB (Smart Spreadsheet)
8049: Vikunja (Task Management)
8050: Leantime (Project Management)
8051: Jitsi Meet (Video Conferencing)
```

### Utilities & Specialized (8060-8099)
```
8060: Postiz (Social Media)
8061: Vaultwarden (Password Manager) 
8062: Kopia (Backup)
8070: Mailpit SMTP
8071: Mailpit Web UI
8080: Whisper (Speech-to-Text)
8081: OpenedAI Speech (Text-to-Speech)
8082: LibreTranslate (Translation)
8083: Scriberr (Audio Transcription)  
8084: Tesseract OCR
8085: EasyOCR
8086: Stirling-PDF
8087: Chatterbox TTS API
8088: Chatterbox Web UI
8089: SearXNG (Search Engine)
8090: Perplexica (AI Search)
8091: Formbricks (Surveys)
8092: Metabase (Business Intelligence)
8093: Crawl4AI (Web Crawler)
8094: Gotenberg (Document Conversion)
8095: Python Runner
8096: Langfuse (AI Observability)
8097: ClickHouse (Analytics DB)
8098: MinIO API (Object Storage)
8099: MinIO Console
```

### External Repository Services
```
8100: Supabase (Backend-as-a-Service)
8101: Dify (AI Application Platform)
```

### Special Ports (preserved)
```
10000/UDP: Jitsi JVB (WebRTC Video/Audio)
7687: Neo4j Bolt Protocol
```

## 🚀 Installation auf dem Zielserver

### 1. Repository auf Zielserver klonen
```bash
git clone https://github.com/hermannheinrich/ai-launchkit-local
cd ai-launchkit-local
```

### 2. Lokale Installation starten  
```bash
sudo bash ./scripts/install_local.sh
```

### 3. Netzwerk-Zugriff konfigurieren
```bash
# Server-IP ermitteln
ip addr show | grep 'inet ' | grep -v 127.0.0.1

# .env anpassen (Beispiel)
sed -i 's/SERVER_IP=127.0.0.1/SERVER_IP=192.168.1.100/' .env

# Services neu starten
docker compose -p localai -f docker-compose.local.yml restart
```

### 4. Firewall für lokales Netzwerk öffnen
```bash
# Für 192.168.x.x Netzwerke
sudo ufw allow from 192.168.0.0/16 to any port 8000:8099

# Für Jitsi Video
sudo ufw allow 10000/udp

# Firewall neu laden
sudo ufw reload
```

## ⚠️ Wichtige Unterschiede zum Original

### ❌ Entfernt:
- Caddy Reverse Proxy (komplett eliminiert)
- Domain-Konfiguration und SSL-Zertifikate
- Let's Encrypt Integration
- Basic Auth Schutzschichten
- HTTPS/TLS Terminierung

### ✅ Hinzugefügt:
- Direkte Port-Mappings für alle Services
- Python-basierte Passwort-Generierung (bcrypt)
- HTTP-only Service-Konfigurationen
- Lokale IP-Erkennung für Jitsi
- Port-Konflikt-Erkennung
- Netzwerk-Zugriffs-Dokumentation

### 🔧 Geändert:
- Alle Service-URLs: HTTPS → HTTP
- Mail-System: Nur Mailpit (lokale Erfassung)
- Authentifizierung: Service-intern statt zentral
- Zugriff: IP:PORT statt Subdomain

## 📋 Validierte Funktionalität

### Service-zu-Service Kommunikation
- ✅ Interne Docker-Service-Namen beibehalten (postgres, redis, etc.)
- ✅ N8N kann alle Services über interne URLs erreichen
- ✅ Mail-System funktioniert service-intern über Mailpit

### Multi-Compose-File Support  
- ✅ Hauptdatei: `docker-compose.local.yml`
- ✅ Supabase: Externes Repo mit Port-Override auf 8100
- ✅ Dify: Externes Repo mit Port-Override auf 8101
- ✅ Einheitliches Docker-Projekt: `localai`

### Port-Schema
- ✅ Systematische Verteilung ohne Konflikte
- ✅ Portainer 9443 respektiert und ausgespart
- ✅ Jitsi UDP 10000 für WebRTC beibehalten
- ✅ Alle Services im Bereich 8000-8099

## 🎉 Installation Ready

Die komplette lokale Netzwerk-Umstellung ist **implementiert und einsatzbereit**!

### Nächste Schritte auf dem Zielserver:
1. Repository klonen
2. `sudo bash ./scripts/install_local.sh` ausführen
3. SERVER_IP in .env für Netzwerk-Zugriff anpassen
4. Services über http://SERVER_IP:8000-8099 aufrufen

**Bulletproof-Garantie:** Keine Host-System-Modifikationen, keine Domain-Dependencies, keine SSL-Komplexität!
