# 🎓 Local AI Learning Kit

<div align="center">

**Learn, Experiment, and Master AI Development**

*40+ AI services for education and testing via IP:PORT - Perfect for learning without production complexity*

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Based on](https://img.shields.io/badge/Based%20on-ai--launchkit-green)](https://github.com/freddy-schuetz/ai-launchkit)

[Quick Start](#-quick-start) • [Service Ports](#-service-port-schema) • [Network Configuration](#-network-access) • [Troubleshooting](#-troubleshooting)

</div>

---

## 🎯 What is AI LaunchKit Local?

This is a **port-based local network version** of the AI LaunchKit that runs completely in Docker containers without requiring domain configuration, SSL certificates, or host system modifications. Perfect for local development, testing, and private networks.

### Key Differences from Original:
- ✅ **No Domains Required** - Access via IP:PORT (e.g., 192.168.1.100:8000)
- ✅ **No SSL Setup** - HTTP-only for local network use
- ✅ **No Caddy/Reverse Proxy** - Direct port access to services
- ✅ **No Host Modifications** - Everything runs in Docker containers
- ✅ **Local Network Ready** - Designed for LAN access from multiple devices

## 🚀 Quick Start

### Prerequisites

1. **Server**: Ubuntu 24.04 LTS (64-bit) with fresh installation
2. **Resources**: 
   - Minimum: 4 GB RAM, 2 CPU cores, 30GB disk
   - Recommended: 16+ GB RAM, 8+ CPU cores, 120GB disk
3. **Network**: Local network access (no internet domain needed)
4. **Docker Management**: Portainer will be installed automatically if not present

### One-Command Installation

```bash
# Clone and install
git clone https://github.com/hermannheinrich/ai-launchkit-local
cd ai-launchkit-local
sudo bash ./scripts/install_local.sh
```

**Installation time:** 10-15 minutes (plus optional n8n workflows import)

### What Gets Installed

The installer will:
1. ✅ Update system and install Docker
2. ✅ Generate secure passwords and API keys
3. ✅ Configure services for local network access
4. ✅ Start selected services with port mappings
5. ✅ Generate access report with all URLs

**No domain prompts, no SSL setup, no host system changes!**

---

## 🌐 Service Port Schema

All services are accessible via `http://SERVER_IP:PORT`:

### Core Services (8000-8019)
| Port | Service | Description |
|------|---------|-------------|
| 8000 | n8n | Workflow Automation Platform |
| 8001 | PostgreSQL | Database (external access) |
| 8002 | Redis | Cache Database (external access) |
| 8003 | Grafana | Monitoring Dashboards |
| 8004 | Prometheus | Metrics Collection |
| 8005 | Node Exporter | System Metrics |
| 8006 | cAdvisor | Container Monitoring |
| 8007 | Portainer | Docker Management UI |

### AI Services (8020-8039)
| Port | Service | Description |
|------|---------|-------------|
| 8020 | Open WebUI | ChatGPT-like Interface |
| 8021 | Ollama | Local LLM Runtime |
| 8022 | Flowise | AI Agent Builder |
| 8023 | bolt.diy | AI Web Development |
| 8024 | ComfyUI | Image Generation |
| 8025 | OpenUI | AI UI Component Generator |
| 8026 | Qdrant | Vector Database |
| 8027 | Weaviate | Vector Database with API |
| 8028 | Neo4j | Graph Database |
| 8029 | LightRAG | Graph-based RAG |
| 8030 | RAGApp | RAG Interface |
| 8031 | Letta | Agent Server |

### Learning Tools (8040-8050)
| Port | Service | Description |
|------|---------|-------------|
| 8040 | Cal.com | Scheduling Platform |
| 8047 | Baserow | Airtable Alternative |
| 8048 | NocoDB | Smart Spreadsheet |
| 8049 | Vikunja | Task Management |
| 8050 | Leantime | Project Management |

### Utilities (8060-8079)
| Port | Service | Description |
|------|---------|-------------|
| 8060 | Postiz | Social Media Manager |
| 8061 | Vaultwarden | Password Manager |
| 8062 | Kopia | Backup System |

### Mail Services (8071 only - Learning/Testing)
| Port | Service | Description |
|------|---------|-------------|
| 8071 | Mailpit Web UI | Email catcher for development & testing |

**Note:** Mailpit captures ALL emails for learning purposes. No external email delivery.

### Specialized Services (8080-8099)
| Port | Service | Description |
|------|---------|-------------|
| 8080 | Whisper | Speech-to-Text |
| 8081 | OpenedAI-Speech | Text-to-Speech |
| 8082 | LibreTranslate | Translation Service |
| 8083 | Scriberr | Audio Transcription |
| 8084 | Tesseract OCR | Text Recognition (Fast) |
| 8085 | EasyOCR | Text Recognition (Quality) |
| 8086 | Stirling-PDF | PDF Tools Suite |
| 8087 | Chatterbox TTS | Advanced Text-to-Speech |
| 8088 | Chatterbox UI | TTS Web Interface |
| 8089 | SearXNG | Private Search Engine |
| 8090 | Perplexica | AI Search Engine |
| 8091 | Formbricks | Survey Platform |
| 8092 | Metabase | Business Intelligence |
| 8093 | Crawl4AI | Web Crawler |
| 8094 | Gotenberg | Document Conversion |
| 8095 | Python Runner | Custom Python Scripts |

### AI Observability Stack (8096-8099)
| Port | Service | Description |
|------|---------|-------------|
| 8096 | Langfuse | LLM Performance Tracking |
| 8097 | ClickHouse | Analytics Database |
| 8098 | MinIO | Object Storage |
| 8099 | MinIO Console | Storage Management |

### External Repository Services
| Port | Service | Description |
|------|---------|-------------|
| 8100 | Supabase | Backend-as-a-Service |
| 8101 | Dify | AI Application Platform |

### Special Ports
| Port | Service | Protocol | Description |
|------|---------|----------|-------------|
| 7687 | Neo4j Bolt | TCP | Graph Database Protocol |

---

## 🎓 Learning Use Cases

This AI LaunchKit is designed for **hands-on learning and experimentation**. Here are practical learning scenarios for each service category:

### 🤖 AI Core Services

**n8n - Workflow Automation Learning**
- **Beginner:** Build your first "Hello World" workflow with 300+ templates
- **Intermediate:** Connect Ollama LLM to process incoming webhooks and auto-respond
- **Advanced:** Create multi-agent AI systems using tools, memory, and conditional logic

**Ollama - Local LLM Experimentation**
- **Beginner:** Run your first local AI model (qwen2.5:7b) and compare with GPT-4
- **Intermediate:** Test different models for specific tasks (coding, translation, analysis)
- **Advanced:** Fine-tune models and benchmark performance metrics

**Flowise - AI Agent Builder**
- **Beginner:** Build a chatbot using drag-and-drop nodes in 5 minutes
- **Intermediate:** Create a RAG system that searches your documents using Qdrant
- **Advanced:** Build autonomous agents with tool-calling and memory management

**Open WebUI - Prompt Engineering Lab**
- **Beginner:** Learn effective prompt engineering with instant feedback
- **Intermediate:** Compare different models side-by-side for the same prompts
- **Advanced:** Create custom model pipelines and share them with your team

### 🗄️ RAG & Vector Databases

**Qdrant - Semantic Search Learning**
- **Beginner:** Upload documents and perform your first vector similarity search
- **Intermediate:** Build a "Chat with your PDFs" application using n8n
- **Advanced:** Implement hybrid search combining keywords and semantic vectors

**Weaviate - AI-Powered Recommendations**
- **Beginner:** Import product data and get AI-generated recommendations
- **Intermediate:** Build a content recommendation engine with custom schemas
- **Advanced:** Implement multi-modal search across text, images, and metadata

**LightRAG - Graph-Based Retrieval**
- **Beginner:** Understand how knowledge graphs improve RAG accuracy
- **Intermediate:** Build a question-answering system with relationship awareness
- **Advanced:** Combine graph structure with vector embeddings for complex queries

**Neo4j - Graph Database Mastery**
- **Beginner:** Model real-world relationships (social networks, org charts)
- **Intermediate:** Write Cypher queries to find patterns in connected data
- **Advanced:** Build recommendation engines using graph algorithms

### 📚 Learning Tools

**Cal.com - Scheduling Automation**
- **Beginner:** Set up automated meeting scheduling with calendar sync
- **Intermediate:** Create custom booking workflows with n8n webhooks
- **Advanced:** Build AI-assisted meeting preparation with pre-call research

**Baserow & NocoDB - No-Code Database Learning**
- **Beginner:** Create your first database with forms and views in the browser
- **Intermediate:** Connect to n8n workflows for automated data processing
- **Advanced:** Build custom business applications with API integrations

**Vikunja & Leantime - Project Management Workflows**
- **Beginner:** Organize personal projects with Kanban boards and Gantt charts
- **Intermediate:** Automate task creation from emails using n8n + Mailpit
- **Advanced:** Build AI-powered project analysis and reporting systems

### 🎨 Specialized AI Services

**ComfyUI - Image Generation Pipelines**
- **Beginner:** Generate your first AI image using pre-built workflows
- **Intermediate:** Create custom node graphs for specific art styles
- **Advanced:** Build automated image processing pipelines with batch operations

**bolt.diy - AI Coding Assistant**
- **Beginner:** Generate a complete web app from a simple prompt
- **Intermediate:** Learn how AI assistants structure projects and write code
- **Advanced:** Compare Claude, GPT-4, and Groq for different coding tasks

**Whisper + TTS - Voice AI Learning**
- **Beginner:** Transcribe audio files and convert text back to speech
- **Intermediate:** Build voice-controlled workflows with n8n
- **Advanced:** Create real-time voice translation systems

**OCR Bundle - Document Processing**
- **Beginner:** Extract text from images and PDFs automatically
- **Intermediate:** Build automated invoice processing with n8n workflows
- **Advanced:** Compare Tesseract (fast) vs EasyOCR (accurate) for different document types

**LibreTranslate - Translation Experiments**
- **Beginner:** Translate text in 20+ languages without external APIs
- **Intermediate:** Build multilingual content workflows with n8n
- **Advanced:** Compare neural translation quality across different language pairs

**Perplexica & SearXNG - Search Engine Learning**
- **Beginner:** Understand privacy-focused search without tracking
- **Intermediate:** Build custom search APIs with filtering and ranking
- **Advanced:** Create AI-enhanced research workflows combining search + LLM analysis

### 🔗 Integration Learning Patterns

**Pattern 1: n8n + Ollama + Qdrant**
Build a complete RAG system that:
1. Indexes documents into Qdrant
2. Retrieves relevant context on questions
3. Uses Ollama to generate informed answers

**Pattern 2: Whisper + LLM + TTS**
Create a voice assistant that:
1. Transcribes speech with Whisper
2. Processes with local LLM
3. Responds with natural TTS

**Pattern 3: Crawl4AI + LLM + Email**
Build a research assistant that:
1. Crawls websites on schedule
2. Summarizes content with LLM
3. Emails digests via Mailpit

**Pattern 4: Cal.com + n8n + LLM**
Create smart scheduling that:
1. Receives booking webhooks
2. Analyzes meeting context with AI
3. Prepares briefing materials

### 📊 Learning Paths

**Path 1: AI Automation Fundamentals (1-2 weeks)**
1. Set up n8n + Ollama + Mailpit
2. Build 5 basic workflows with templates
3. Create your first AI-powered automation

**Path 2: RAG System Development (2-4 weeks)**
1. Learn vector databases with Qdrant
2. Build document ingestion pipelines
3. Create production-ready RAG applications

**Path 3: Multi-Agent Systems (4-8 weeks)**
1. Master Flowise agent building
2. Implement tool-calling and memory
3. Build autonomous multi-agent workflows

**Path 4: Voice AI Development (2-3 weeks)**
1. Learn transcription with Whisper
2. Process audio with LLMs
3. Generate natural speech responses

### 💡 Learning Tips

**Start Small:** Begin with 3-5 core services (n8n, Ollama, Flowise, Mailpit, Monitoring)

**Progressive Complexity:** Master one service before adding others

**Documentation Everything:** Use n8n's notes feature to document your learning

**Experiment Safely:** All services are isolated in Docker - break things and rebuild!

**Monitor Performance:** Use Grafana to understand resource usage patterns

**Join Community:** Share your learning projects in forums and Discord

---

## 🌐 Network Access

### Automatic LAN Configuration (Default)

**During installation, the wizard will:**
1. ✅ **Auto-detect your server's LAN IP** (e.g., 192.168.1.100)
2. ✅ **Configure SERVER_IP automatically** in .env
3. ✅ **Set up firewall rules** for LAN access (ports 8000-8099)

**After installation, services are immediately accessible from ANY device:**
```
http://192.168.1.100:8000  # n8n from laptop
http://192.168.1.100:8022  # Flowise from phone
http://192.168.1.100:8003  # Grafana from tablet
http://192.168.1.100:8071  # Email interface from any device
```

**No manual configuration needed!** Just open the URL from any device on your network.

### Localhost Only (Alternative)

If you declined LAN access during installation, services use localhost:
```bash
# Access only from server
http://127.0.0.1:8000  # n8n
http://127.0.0.1:8022  # Flowise  
http://127.0.0.1:8003  # Grafana
```

To enable LAN access later:
1. Find your LAN IP: `ip addr show | grep 'inet ' | grep -v 127.0.0.1`
2. Update .env: `sed -i 's/SERVER_IP=127.0.0.1/SERVER_IP=192.168.1.100/' .env`
3. Restart: `docker compose -p localai -f docker-compose.local.yml restart`
4. Add firewall rules: `sudo ufw allow from 192.168.0.0/16 to any port 8000:8099`

### Firewall Status

Check your current firewall configuration:
```bash
# View firewall status
sudo ufw status

# If LAN access wasn't configured during installation, add it manually:
sudo ufw allow from 192.168.0.0/16 to any port 8000:8099
sudo ufw allow from 10.0.0.0/8 to any port 8000:8099
sudo ufw reload
```

---

## ⚙️ Configuration

### Environment File

The local network configuration uses `.env.local.example` as template:

```bash
# Copy template to active configuration
cp .env.local.example .env

# Edit configuration
nano .env
```

### Key Configuration Variables

```bash
# Network Configuration
SERVER_IP=127.0.0.1          # Change to your LAN IP
N8N_WORKER_COUNT=1           # Number of n8n workers

# Service Selection
COMPOSE_PROFILES="n8n,flowise,monitoring"

# Mail Configuration (Local Network)
MAIL_MODE=mailpit
SMTP_HOST=mailpit
SMTP_PORT=1025
EMAIL_FROM=noreply@localhost

# Optional AI API Keys
OPENAI_API_KEY=              # For enhanced AI features
ANTHROPIC_API_KEY=           # For Claude models
GROQ_API_KEY=               # For fast inference
```

### Service Selection

Choose which services to install by editing `COMPOSE_PROFILES`:

```bash
# Minimal installation
COMPOSE_PROFILES="n8n,flowise"

# Full AI stack
COMPOSE_PROFILES="n8n,flowise,open-webui,cpu,comfyui,monitoring"

# Learning suite
COMPOSE_PROFILES="n8n,calcom,baserow,nocodb,vikunja,leantime,vaultwarden"

# Complete installation (all services)
COMPOSE_PROFILES="n8n,flowise,monitoring,bolt,openui,comfyui,cpu,calcom,baserow,nocodb,vikunja,leantime,vaultwarden,langfuse,qdrant,weaviate,neo4j,lightrag,speech,ocr,libretranslate"
```

---

## 🗑️ Uninstalling AI LaunchKit

If you need to remove AI LaunchKit from your system:

### Safe Uninstall with Backup

```bash
# Run the uninstall script
sudo bash ./scripts/uninstall_local.sh
```

The uninstall script will:
1. ✅ Show current AI LaunchKit status
2. ✅ Ask for confirmation before proceeding
3. ✅ Offer to create backup (workflows, databases, volumes)
4. ✅ Remove only AI LaunchKit containers and volumes
5. ✅ Preserve Portainer (or install it if missing)
6. ✅ Optionally keep or remove .env configuration

### Manual Uninstall

If you prefer manual removal:

```bash
# Stop all services
docker compose -p localai -f docker-compose.local.yml down

# Remove with volumes (⚠️ DATA LOSS!)
docker compose -p localai -f docker-compose.local.yml down -v

# Remove images (optional)
docker image prune -a -f --filter "label=com.docker.compose.project=localai"
```

### What Gets Removed

- ❌ All AI LaunchKit containers (n8n, Flowise, Ollama, etc.)
- ❌ All data volumes (workflows, databases, uploaded files)
- ❌ AI LaunchKit Docker networks
- ❌ Unused AI LaunchKit Docker images

### What Gets Preserved

- ✅ Portainer (Docker Management UI)
- ✅ Other Docker containers not part of AI LaunchKit
- ✅ Project directory and scripts (can reinstall anytime)
- ✅ Your .env configuration (optionally backed up)

---

## 🔧 Management Commands

### Service Management
```bash
# Start all services
docker compose -p localai -f docker-compose.local.yml up -d

# Stop all services  
docker compose -p localai -f docker-compose.local.yml down

# Restart specific service
docker compose -p localai -f docker-compose.local.yml restart n8n

# View service logs
docker compose -p localai -f docker-compose.local.yml logs n8n

# Check running services
docker ps

# Monitor resources
docker stats
```

### Service Health Checks
```bash
# Check all service health
./scripts/06_final_report_local.sh

# Test specific port
nc -z localhost 8000

# Check port usage
netstat -tuln | grep 80
```

### Updates
```bash
# Pull latest images
docker compose -p localai -f docker-compose.local.yml pull

# Restart with updates
docker compose -p localai -f docker-compose.local.yml up -d

# Clean up old images
docker image prune -f
```

---

## 📊 Service-Specific Configuration

### n8n Workflow Automation
- **Access:** http://SERVER_IP:8000
- **First login:** Create admin account on first visit
- **Workflows:** 300+ templates can be imported during installation
- **API:** Internal services use `http://n8n:5678`

### Grafana Monitoring
- **Access:** http://SERVER_IP:8003
- **Login:** admin / [Check GRAFANA_ADMIN_PASSWORD in .env]
- **Dashboards:** Pre-configured for Docker monitoring
- **Data Sources:** Prometheus, PostgreSQL

### Mailpit Email Testing
- **Web UI:** http://SERVER_IP:8071
- **SMTP:** SERVER_IP:8070 (port 1025 internal)
- **Purpose:** Captures all outgoing emails from services
- **No Auth:** Open access for local network

### Jitsi Meet Video Conferencing
- **Access:** http://SERVER_IP:8051
- **Rooms:** http://SERVER_IP:8051/your-room-name
- **⚠️ Requirements:** UDP port 10000 must be open
- **Test Audio/Video:** Create room with 2+ participants

### Database Access
- **PostgreSQL:** SERVER_IP:8001
- **Username:** postgres
- **Password:** Check POSTGRES_PASSWORD in .env
- **Databases:** Multiple apps share this instance

---

## 🔐 Security for Local Networks

### Network Isolation
- Services only accessible from local network
- No external SSL certificates
- No internet-facing endpoints
- Docker network isolation between services

### Authentication
- **Disabled by default** for local network convenience
- Each service has its own user management system
- Passwords stored in .env file
- No Basic Auth layers (unlike original)

### Production Considerations
If deploying to production network:
1. Enable authentication on individual services
2. Configure SSL termination (nginx/Apache)
3. Restrict network access with firewall rules
4. Use strong passwords and API keys
5. Consider VPN access for remote users

---

## 🌐 Network Access Examples

### From Server (Localhost)
```bash
# n8n Workflow Automation
curl http://127.0.0.1:8000

# Flowise AI Agent Builder  
curl http://127.0.0.1:8022

# Grafana Monitoring
curl http://127.0.0.1:8003
```

### From Network Device
```bash
# Replace 192.168.1.100 with your server's IP
curl http://192.168.1.100:8000  # n8n
curl http://192.168.1.100:8022  # Flowise
curl http://192.168.1.100:8003  # Grafana

# From browser on phone/laptop/tablet
http://192.168.1.100:8000  # n8n interface
http://192.168.1.100:8071  # Email interface
http://192.168.1.100:8051/meeting  # Jitsi meeting
```

### API Integration
```javascript
// n8n webhook from external service
POST http://192.168.1.100:8000/webhook/your-webhook-id

// Ollama API call
POST http://192.168.1.100:8021/api/generate
{
  "model": "qwen2.5:7b-instruct-q4_K_M", 
  "prompt": "Hello world"
}

// Vector search with Qdrant
POST http://192.168.1.100:8026/collections/search
```

---

## 📧 Mail System

### Mailpit (Always Active)
- **Purpose:** Captures ALL emails sent by any service
- **Web Interface:** http://SERVER_IP:8071
- **SMTP Server:** SERVER_IP:8070 (internal port 1025)
- **Authentication:** None needed (local network)
- **Storage:** Emails stored in Docker volume (mailpit_data)

### Configuration for Services
All services automatically use Mailpit:
```bash
SMTP_HOST=mailpit
SMTP_PORT=1025  
SMTP_USER=admin
SMTP_PASS=admin
SMTP_SECURE=false
```

### Testing Email
1. Open any service that sends emails (n8n, Cal.com, etc.)
2. Trigger an email action
3. Check Mailpit web interface: http://SERVER_IP:8071
4. View email content, headers, attachments

---

## 🔧 Troubleshooting

### Services Not Starting

**Check port conflicts:**
```bash
netstat -tuln | grep 80
# Look for ports in range 8000-8099
```

**Check Docker resources:**
```bash
docker stats
free -h
df -h
```

**View service logs:**
```bash
docker compose -p localai -f docker-compose.local.yml logs [service_name]
```

### Network Access Issues

**Can't access from other devices:**
1. Check SERVER_IP in .env matches server's LAN IP
2. Verify firewall allows access:
   ```bash
   sudo ufw status
   sudo ufw allow from 192.168.1.0/24 to any port 8000:8099
   ```
3. Test connectivity: `telnet SERVER_IP 8000`

**Services returning 404/502:**
1. Wait 2-3 minutes for services to fully start
2. Check service is running: `docker ps | grep service_name`
3. Check port binding: `docker port container_name`

### Database Connection Issues

**Services can't connect to PostgreSQL:**
```bash
# Check PostgreSQL is running
docker ps | grep postgres

# Test connection from service
docker exec n8n nc -zv postgres 5432

# Check logs
docker logs postgres
```

### Performance Issues

**High memory usage:**
```bash
# Reduce n8n workers
echo "N8N_WORKER_COUNT=1" >> .env
docker compose -p localai -f docker-compose.local.yml restart

# Disable resource-heavy services temporarily
docker compose -p localai -f docker-compose.local.yml stop comfyui langfuse-web
```

**Slow response times:**
- Check available RAM: `free -h`
- Monitor CPU: `htop`
- Add swap: `sudo fallocate -l 4G /swapfile && sudo swapon /swapfile`

### Common Service Issues

<details>
<summary><b>n8n Not Accessible</b></summary>

```bash
# Check n8n container status
docker logs n8n --tail 50

# Check database connection
docker exec n8n nc -zv postgres 5432

# Restart n8n
docker compose -p localai -f docker-compose.local.yml restart n8n
```

**Common causes:**
- Database not ready (wait 2-3 minutes)
- Workflow import still running (check `docker logs n8n-import`)
- Port 8000 already in use

</details>

<details>
<summary><b>Flowise Not Loading</b></summary>

```bash
# Check Flowise logs
docker logs flowise --tail 50

# Verify port binding
docker port flowise

# Test direct access
curl http://localhost:8022
```

**Common causes:**
- Container still initializing (wait 1-2 minutes)
- Port conflict on 8022
- Missing environment variables

</details>

<details>
<summary><b>Email Not Working</b></summary>

```bash
# Check Mailpit is running
docker ps | grep mailpit

# Test SMTP connection
docker exec n8n nc -zv mailpit 1025

# Check Mailpit logs
docker logs mailpit
```

**Email test:**
1. Open n8n: http://SERVER_IP:8000
2. Create simple workflow: Manual Trigger → Send Email
3. Execute workflow
4. Check emails: http://SERVER_IP:8071

</details>

---

## 📈 Performance Optimization

### Resource Requirements by Service Count

**Minimal (n8n + Flowise + Monitoring):**
- RAM: 4GB
- CPU: 2 cores
- Services: ~8 containers

**Standard (+ Business Tools):**
- RAM: 8GB  
- CPU: 4 cores
- Services: ~15 containers

**Full Stack (All Services):**
- RAM: 16GB+
- CPU: 8 cores
- Services: 40+ containers

### Performance Tuning

**Reduce n8n workers:**
```bash
echo "N8N_WORKER_COUNT=1" >> .env
```

**Optimize Baserow:**
```bash
# Already configured in docker-compose:
BASEROW_RUN_MINIMAL=yes
BASEROW_AMOUNT_OF_WORKERS=1
```

**Limit LibreTranslate models:**
```bash
echo "LIBRETRANSLATE_LOAD_ONLY=en,de,fr" >> .env
```

**Disable telemetry:**
Services have telemetry disabled by default for privacy and performance.

---

## 🔄 Migration from Domain-based Installation

If you have an existing domain-based AI LaunchKit installation:

### Backup Data
```bash
# Export n8n workflows
docker exec n8n n8n export:workflow --backup --output=/backup/workflows.json

# Backup databases
docker exec postgres pg_dumpall -U postgres > backup.sql

# Backup volumes
docker run --rm -v localai_n8n_storage:/data -v $(pwd):/backup alpine \
  tar czf /backup/n8n_backup.tar.gz /data
```

### Migration Steps
1. Deploy this local version on a new server
2. Import workflows via n8n interface
3. Restore database data if needed
4. Update any hardcoded URLs in workflows
5. Test all integrations with new IP:PORT format

---

## 🆘 Support

### Documentation
- **Original Project:** [AI LaunchKit](https://github.com/freddy-schuetz/ai-launchkit)
- **Local Version:** This README
- **Service URLs:** Generated `LOCAL_ACCESS_URLS.txt`

### Getting Help
1. **Check Logs:** `docker compose logs [service_name]`
2. **Service Status:** `docker ps`
3. **Resource Usage:** `docker stats`
4. **Port Conflicts:** `netstat -tuln | grep 80`

### Reporting Issues
- **GitHub:** [Report local network issues](https://github.com/hermannheinrich/ai-launchkit-local/issues)
- **Original:** [AI LaunchKit issues](https://github.com/freddy-schuetz/ai-launchkit/issues)

### Community
- **Forum:** [oTTomator Think Tank](https://thinktank.ottomator.ai/c/local-ai/18)
- **Discord:** Join the AI development community

---

## 📁 File Structure

```
ai-launchkit-local/
├── docker-compose.local.yml        # Port-based service definitions
├── .env.local.example              # Local network configuration template  
├── start_services_local.py         # Service orchestration script
├── LOCAL_ACCESS_URLS.txt           # Generated access URLs
├── scripts/
│   ├── install_local.sh            # Main installation script
│   ├── 03_generate_secrets_local.sh # Password generation (no Caddy)
│   ├── 04_wizard_local.sh          # Service selection (no domains)
│   ├── 05_run_services_local.sh    # Service startup (port-based)
│   └── 06_final_report_local.sh    # Access report generation
├── shared/                         # Shared files between services
├── media/                          # Media processing files
├── temp/                           # Temporary processing files
└── [service directories]/          # Individual service configurations
```

---

## 🔄 Advanced Usage

### Custom Service Configuration

**Add custom ports:**
```yaml
# In docker-compose.local.yml
services:
  my-service:
    image: my-app:latest
    ports:
      - "8999:3000"  # Use ports outside main range
```

**Custom environment:**
```bash
# In .env
MY_SERVICE_CONFIG=value
MY_API_KEY=secret
```

### Integration Examples

**n8n workflow calling Ollama:**
```javascript
// HTTP Request Node in n8n
Method: POST
URL: http://ollama:11434/api/generate
Body: {
  "model": "qwen2.5:7b-instruct-q4_K_M",
  "prompt": "Hello from n8n workflow!"
}
```

**External API calling services:**
```javascript
// From external application
const response = await fetch('http://192.168.1.100:8000/webhook/my-webhook', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ message: 'Hello AI LaunchKit!' })
});
```

### Multi-Server Setup

Deploy multiple instances:
```bash
# Server 1: Core AI services
COMPOSE_PROFILES="n8n,flowise,cpu,open-webui,monitoring"

# Server 2: RAG & Vector databases  
COMPOSE_PROFILES="qdrant,weaviate,neo4j,lightrag,ragapp"

# Server 3: Specialized services
COMPOSE_PROFILES="speech,ocr,libretranslate,stirling-pdf,comfyui"
```

---

## 📜 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

Based on [AI LaunchKit](https://github.com/freddy-schuetz/ai-launchkit) by Friedemann Schuetz.

---

<div align="center">

**Ready to launch your local AI stack?**

[🐛 Report local issues](https://github.com/hermannheinrich/ai-launchkit-local/issues) • [📚 View original project](https://github.com/freddy-schuetz/ai-launchkit)

</div>
