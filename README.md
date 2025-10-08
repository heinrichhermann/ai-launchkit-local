# 🏠 AI LaunchKit - Local Network Edition

<div align="center">

**Your Complete AI Stack for Local Networks**

*40+ AI services accessible via IP:PORT - Perfect for learning, development, testing, and private team collaboration without domain/SSL complexity*

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Based on](https://img.shields.io/badge/Based%20on-ai--launchkit-green)](https://github.com/freddy-schuetz/ai-launchkit)

[Quick Start](#-quick-start) • [Service Ports](#-service-port-schema) • [Network Configuration](#-network-access) • [Troubleshooting](#-troubleshooting)

</div>

---

## 🎯 What is AI LaunchKit Local?

This is a **port-based local network version** of the AI LaunchKit that runs completely in Docker containers without requiring domain configuration, SSL certificates, or host system modifications.

**Perfect for:**
- 🎓 **Learning & Experimentation** - Safe environment to learn AI technologies
- 💼 **Professional Use** - Private AI stack for teams and organizations  
- 🧪 **Development & Testing** - Full-featured environment for building AI applications
- 🏢 **Local Deployment** - Keep all data on-premises in your network
- 👥 **Team Collaboration** - Share AI services with colleagues on same network

### Key Differences from Original:
- ✅ **No Domains Required** - Access via IP:PORT (e.g., 192.168.1.100:8000)
- ✅ **No SSL Setup** - HTTP-only for local network use
- ✅ **No Caddy/Reverse Proxy** - Direct port access to services
- ✅ **No Host Modifications** - Everything runs in Docker containers
- ✅ **Local Network Ready** - Designed for LAN access from multiple devices
- ✅ **Production-Grade** - Same services as cloud version, just local

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
# Clone and install in one command
git clone https://github.com/hermannheinrich/ai-launchkit-local && cd ai-launchkit-local && sudo bash ./scripts/install_local.sh
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

## 📖 Step-by-Step Installation Guide (For Beginners)

**Perfect for:** People new to Linux, AI, or Docker
**Time needed:** 30-45 minutes
**Experience level:** No prior knowledge required!

### What You Need:

✅ **A Server or Computer running Ubuntu**
- Minimum: 4 GB RAM, 2 CPU cores, 30GB disk
- Recommended: 8+ GB RAM, 4+ CPU cores
- Fresh Ubuntu 24.04 LTS installation

✅ **Access to the Server**
- SSH connection OR direct console access
- Administrator (sudo) rights

✅ **Internet Connection**
- For downloading Docker images and services

❌ **What You DON'T Need:**
- Domain name or website
- SSL certificates
- Advanced Linux knowledge
- Programming experience

---

### Step 1: Connect to Your Ubuntu Server

**What happens:** You'll open a terminal and connect to your server

<details>
<summary><b>📖 Detailed Connection Instructions</b></summary>

**Option A: Using SSH (Remote Connection)**

If your server is in another room or location:

1. **Find your server's IP address**
   - Usually printed during Ubuntu installation
   - Or check your router's connected devices
   - Example: `192.168.1.100`

2. **Open Terminal/SSH Client:**
   - **Windows:** Download [PuTTY](https://www.putty.org/) or use Windows Terminal
   - **Mac:** Open Terminal app (⌘+Space, type "Terminal")
   - **Linux:** Open Terminal (Ctrl+Alt+T)

3. **Connect via SSH:**
   ```bash
   ssh your-username@192.168.1.100
   ```
   Replace:
   - `your-username` with your Ubuntu username
   - `192.168.1.100` with your server's IP

4. **Enter your password** when prompted
   - You won't see characters while typing - this is normal!
   - Press Enter when done

5. **You're connected!** You should see:
   ```
   username@server:~$
   ```

**Option B: Direct Console Access**

If you're sitting at the server:

1. **Login with your username and password**
2. **You'll see the command prompt:**
   ```
   username@server:~$
   ```
3. **You're ready!**

</details>

---

### Step 2: Download and Start Installation

**What happens:** One command downloads everything and starts the automated installation

**Copy and paste this into your terminal:**
```bash
git clone https://github.com/hermannheinrich/ai-launchkit-local && cd ai-launchkit-local && sudo bash ./scripts/install_local.sh
```

**Press Enter**, then type your password when asked.

<details>
<summary><b>📖 What This Command Does</b></summary>

Breaking down the command:

**Part 1:** `git clone https://github.com/hermannheinrich/ai-launchkit-local`
- Downloads the AI Learning Kit to your server
- Creates folder: `ai-launchkit-local`

**Part 2:** `cd ai-launchkit-local`
- Changes into that folder
- All scripts are now accessible

**Part 3:** `sudo bash ./scripts/install_local.sh`
- `sudo` = Run as administrator (needed for installation)
- `bash` = Execute the script
- `./scripts/install_local.sh` = The installation script

**Why sudo?**
- Installs system packages (Docker, etc.)
- Configures firewall
- Needs administrator privileges

</details>

---

### Step 3: Answer Installation Questions

**What happens:** The wizard asks you a few simple questions to customize your installation

<details>
<summary><b>📖 Question-by-Question Guide</b></summary>

#### Question 1: Configure LAN Access?
```
Allow access from local network (recommended for LAN installation)?
Configure LAN access now? (Y/n):
```

**What to do:** ✅ **Press ENTER** (=Yes)

**What it means:**
- Opens firewall ports for your local network
- Devices on your network can access the services
- Example: Access from your laptop, phone, or tablet

**Technical details:** Adds firewall rules for 192.168.x.x and 10.x.x.x networks

---

#### Question 2: Service Selection
```
Choose services for your local network AI development stack.
[Checkbox menu appears]
```

**What to do:**
1. Use ↑↓ **Arrow keys** to move up/down
2. Press **SPACEBAR** to select/deselect services
3. Press **ENTER** when done

**Recommended for beginners:**
- ✅ n8n (Workflow Automation) - Already selected
- ✅ flowise (AI Agent Builder) - Already selected
- ✅ monitoring (Grafana dashboards) - Already selected
- ⚠️ Leave others unselected for now (you can add later)

**What each service does:**
- **n8n**: Build AI automation workflows (like IFTTT for AI)
- **Flowise**: Create chatbots with drag-and-drop
- **monitoring**: See system performance (RAM, CPU usage)

---

#### Question 3: LAN IP Address
```
✅ Detected LAN IP address: 192.168.1.100
Use this IP address for network access? (Y/n):
```

**What to do:** ✅ **Press ENTER** (=Yes)

**What it means:**
- Your services will be accessible at http://192.168.1.100:PORT
- This IP was automatically detected
- You can change it later if needed

---

#### Question 4: Ollama Hardware Profile
```
Choose the hardware profile for Ollama local LLM runtime.
( ) CPU (Recommended for most users)
( ) NVIDIA GPU (Requires NVIDIA drivers)
( ) AMD GPU (Requires ROCm drivers)
```

**What to do:**
- ✅ **Select "CPU" and press ENTER** (for most users)
- Only choose GPU options if you have a powerful graphics card

**What it means:**
- CPU: Uses processor for AI (slower but works everywhere)
- GPU: Uses graphics card (much faster but needs setup)

---

#### Question 5: Import n8n Workflows?
```
Import workflows? (y/n):
```

**What to do:** ⚠️ **Type `n` and press ENTER** (skip for now)

**Why skip:**
- Takes 30 minutes to import 300+ workflows
- You probably want to explore first
- You can import later anytime

**If you choose yes:**
- Installation continues in background
- Check progress: `docker logs n8n-import`

---

#### Question 6: n8n Worker Count
```
Enter the number of n8n workers to run (default is 1):
```

**What to do:** ✅ **Press ENTER** (use default: 1)

**What it means:**
- Workers process workflows in parallel
- 1 worker is fine for learning
- More workers = can run more workflows simultaneously

---

#### Question 7-9: API Keys (Optional)
```
OpenAI API Key (press Enter to skip):
Anthropic API Key (press Enter to skip):
Groq API Key (press Enter to skip):
```

**What to do:** ✅ **Press ENTER 3 times** (skip all)

**What are these:**
- Optional paid API keys for cloud AI services
- Not needed for local AI with Ollama
- You can add them later in the .env file

---

**Installation Progress:**

You'll now see:
```
========== STEP 1: System Preparation ==========
✅ System preparation complete!

========== STEP 2: Installing Docker ==========
✅ Docker installation complete!

========== STEP 3: Generating Local Network Configuration ==========
✅ Local network configuration complete!

[... more steps ...]

🎉 AI LaunchKit Local Network Installation Complete!
```

**Wait for all steps to complete** (10-15 minutes)

</details>

---

### Step 4: Services Are Ready! 🎉

**What happens:** All services are running, you can start using them immediately!

**You'll see a summary like this:**
```
🎉 INSTALLATION SUCCESSFUL!

Your services are accessible at:
- n8n (Workflow Automation): http://192.168.1.100:8000
- Flowise (AI Agent Builder): http://192.168.1.100:8022
- Grafana (Monitoring): http://192.168.1.100:8003
- Mailpit (Email Testing): http://192.168.1.100:8071
```

**What to do next:**

1. **Open your browser** (can be on any device!)
2. **Navigate to n8n:** `http://YOUR-SERVER-IP:8000`
3. **Create your admin account:**
   - Enter your email
   - Choose a strong password
   - Click "Next"
4. **You're in!** Welcome to n8n 🎉

---

## 🎯 Your First AI Automation (10 Minutes Tutorial)

**Let's build a simple AI workflow to test everything:**

<details>
<summary><b>📖 Complete Beginner Tutorial</b></summary>

### Tutorial: Ask Ollama a Question

**What you'll learn:**
- How to create a workflow in n8n
- How to connect to Ollama (local AI)
- How to see AI responses

**Steps:**

1. **Open n8n:** `http://YOUR-SERVER-IP:8000`

2. **Click the big "+" button** (Create New Workflow)

3. **Click "Add first step"**
   - A panel opens on the right

4. **Search for "Manual Trigger"**
   - Type "manual" in the search box
   - Click "Manual Trigger" when it appears
   - This lets you start the workflow with a button click

5. **Click the "+" icon** next to your Manual Trigger node
   - This adds the next step

6. **Search for "HTTP Request"**
   - Type "http" in the search box
   - Click "HTTP Request"

7. **Configure the HTTP Request:**
   Click on the HTTP Request node and fill in:
   
   - **Method:** Select "POST" from dropdown
   
   - **URL:** Enter this exactly:
     ```
     http://ollama:11434/api/generate
     ```
   
   - **Authentication:** Leave as "None"
   
   - **Send Body:** Toggle ON
   
   - **Body Content Type:** Select "JSON"
   
   - **Specify Body:** Select "Using JSON"
   
   - **JSON:** Paste this:
     ```json
     {
       "model": "qwen2.5:7b-instruct-q4_K_M",
       "prompt": "Hello! Please introduce yourself and explain what you can do.",
       "stream": false
     }
     ```

8. **Click "Execute Workflow"** button (top right)
   - Wait 5-10 seconds for AI to respond

9. **See the result!**
   - Click on the HTTP Request node
   - Look at the "Output" tab
   - You'll see the AI's response in JSON format

**Congratulations!** 🎉 You just created your first AI workflow!

**What just happened:**
- n8n sent a request to Ollama (your local AI)
- Ollama processed your question
- Ollama sent back an answer
- You can now build on this to create complex automations!

**Next steps:**
- Try different prompts
- Add more nodes (email, database, etc.)
- Explore the 300+ workflow templates

</details>

---

## ❓ Frequently Asked Questions

<details>
<summary><b>🖥️ Can I install this on Windows or Mac directly?</b></summary>

**No, not directly.** The AI Kit requires Ubuntu Linux.

**Your options:**

**Option 1: Virtual Machine (Easiest for Windows/Mac)**
1. Install [VirtualBox](https://www.virtualbox.org/) (free)
2. Download [Ubuntu 24.04 LTS](https://ubuntu.com/download/server)
3. Create VM with 8GB RAM, 4 CPU cores, 60GB disk
4. Install Ubuntu in the VM
5. Follow installation guide above
6. Access services from your Windows/Mac browser

**Option 2: Cloud VPS (No local hardware needed)**
1. Rent Ubuntu server from providers like:
   - DigitalOcean ($12/month for 4GB RAM)
   - Linode/Akamai ($10/month for 4GB RAM)
   - Hetzner ($5/month for 4GB RAM - Europe)
2. Get SSH access details
3. Follow installation guide above
4. Access from anywhere

**Option 3: Raspberry Pi (Cheap dedicated hardware)**
- Raspberry Pi 4/5 with 8GB RAM ($80)
- Install Ubuntu Server 24.04
- Perfect for 24/7 operation
- Low power consumption

</details>

<details>
<summary><b>❌ I got an error during installation, what should I do?</b></summary>

**Don't worry!** The system automatically cleans up on errors.

**Steps to resolve:**

1. **Read the error message carefully**
   - It shows exactly which step failed
   - Example: "Installation failed at: Docker Installation"

2. **Check common issues:**
   
   **Error: "Port already in use"**
   - Another program is using that port
   - Check what: `sudo netstat -tuln | grep :8000`
   - Stop that program or choose different port

   **Error: "Out of memory" or "Cannot allocate memory"**
   - Server doesn't have enough RAM
   - Need minimum 4GB RAM
   - Upgrade server or select fewer services

   **Error: "Docker daemon not responding"**
   - Docker installation failed
   - Try: `sudo systemctl status docker`
   - Restart: `sudo systemctl restart docker`

   **Error: "Permission denied"**
   - Not running with sudo
   - Use: `sudo bash ./scripts/install_local.sh`

3. **Try installation again:**
   ```bash
   cd ai-launchkit-local
   sudo bash ./scripts/install_local.sh
   ```
   - Previous failed installation was rolled back automatically
   - Safe to re-run

4. **Still having issues?**
   - Post in [GitHub Issues](https://github.com/hermannheinrich/ai-launchkit-local/issues)
   - Include: Error message, Ubuntu version, server specs
   - Community will help!

</details>

<details>
<summary><b>📱 How do I access services from my phone, laptop, or tablet?</b></summary>

**It's automatic! No configuration needed.**

**Steps:**

1. **Make sure your device is on the same WiFi/network** as the server

2. **Find your server's IP** (shown during installation)
   - Example: `192.168.1.100`

3. **Open any browser** on your device
   - Chrome, Safari, Firefox, Edge - all work!

4. **Type in the address bar:**
   ```
   http://192.168.1.100:8000
   ```
   Replace `192.168.1.100` with YOUR server IP

5. **Done!** Services work identically on all devices

**Examples:**
- **From laptop:** `http://192.168.1.100:8000` (n8n)
- **From phone:** `http://192.168.1.100:8022` (Flowise)
- **From tablet:** `http://192.168.1.100:8003` (Grafana)
- **From any device:** `http://192.168.1.100/` (Dashboard)

**Tip:** Bookmark these URLs on your devices!

</details>

<details>
<summary><b>🗑️ How do I uninstall everything?</b></summary>

**Safe and simple uninstallation with automatic backup:**

```bash
cd ai-launchkit-local
sudo bash ./scripts/uninstall_local.sh
```

**What happens:**

1. **Shows current status**
   - Lists all running services
   - Shows data volumes

2. **Asks for confirmation**
   - Type `yes` to proceed
   - Anything else cancels

3. **Offers backup** (Recommended!)
   - Creates backup of workflows, databases, volumes
   - Saves to: `~/ai-launchkit-backup-YYYYMMDD-HHMMSS/`
   - Press ENTER to accept

4. **Removes AI LaunchKit**
   - Stops all containers
   - Removes data (with your permission)
   - Cleans up Docker images

5. **Preserves important stuff:**
   - ✅ Docker (in case you use it for other things)
   - ✅ Portainer (Docker management tool)
   - ✅ Your project folder (can reinstall anytime)

**After uninstall:**
- Server is back to clean state
- Can reinstall anytime: `sudo bash ./scripts/install_local.sh`
- Or restore from backup

</details>

<details>
<summary><b>🔧 What if I want to change the services later?</b></summary>

**You can easily add or remove services:**

1. **Stop all services:**
   ```bash
   cd ai-launchkit-local
   docker compose -p localai -f docker-compose.local.yml down
   ```

2. **Edit the .env file:**
   ```bash
   nano .env
   ```
   
3. **Find the line starting with:** `COMPOSE_PROFILES=`

4. **Add or remove service names** (comma-separated)
   - Example: `COMPOSE_PROFILES="n8n,flowise,monitoring,cpu,comfyui"`
   - Available: n8n, flowise, bolt, openui, monitoring, cpu, gpu-nvidia, gpu-amd, calcom, baserow, nocodb, vikunja, leantime, and more

5. **Save and exit:**
   - Press `Ctrl+X`
   - Press `Y` (yes, save)
   - Press `Enter`

6. **Start services again:**
   ```bash
   docker compose -p localai -f docker-compose.local.yml up -d
   ```

7. **Wait 2-3 minutes** for new services to start

</details>

<details>
<summary><b>⚡ How do I stop or restart services?</b></summary>

**Stop all services:**
```bash
cd ai-launchkit-local
docker compose -p localai -f docker-compose.local.yml down
```

**Start all services:**
```bash
cd ai-launchkit-local
docker compose -p localai -f docker-compose.local.yml up -d
```

**Restart a specific service** (example: n8n):
```bash
docker compose -p localai -f docker-compose.local.yml restart n8n
```

**See what's running:**
```bash
docker ps
```

**Check service logs** (if something doesn't work):
```bash
docker compose -p localai -f docker-compose.local.yml logs n8n
```
Replace `n8n` with any service name

</details>

<details>
<summary><b>💾 Where is my data stored?</b></summary>

**All data is in Docker volumes:**

**List all volumes:**
```bash
docker volume ls | grep localai_
```

**Your important data:**
- `localai_n8n_storage` - All your workflows
- `localai_langfuse_postgres_data` - All databases
- `localai_ollama_storage` - Downloaded AI models

**Backup data:**
```bash
# During uninstall: Select "Yes" for backup
# Manual backup: Run the uninstall script and it creates automatic backup
```

**Where are backups:**
- Location: `~/ai-launchkit-backup-YYYYMMDD-HHMMSS/`
- Contains: workflows, databases, all volumes as .tar.gz files

</details>

<details>
<summary><b>🆘 I'm stuck! Where can I get help?</b></summary>

**Don't worry - help is available!**

**1. Check the logs:**
```bash
cd ai-launchkit-local
docker compose -p localai -f docker-compose.local.yml logs
```

**2. Check specific service:**
```bash
docker logs n8n
docker logs flowise
docker logs postgres
```

**3. Ask for help:**
- **GitHub Issues:** [Report a problem](https://github.com/hermannheinrich/ai-launchkit-local/issues)
  - Include: Error message, what you were doing, Ubuntu version
  
- **Original AI LaunchKit:** [Main project](https://github.com/freddy-schuetz/ai-launchkit)
  
- **Community Forum:** [oTTomator Think Tank](https://thinktank.ottomator.ai/c/local-ai/18)

**4. Common commands for troubleshooting:**
```bash
# Check if Docker is running
sudo systemctl status docker

# Check system resources
htop  # Press Q to exit

# Check disk space
df -h

# Check memory
free -h

# Restart Docker
sudo systemctl restart docker
```

</details>

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
| Port | Service | Description | Setup Guide |
|------|---------|-------------|-------------|
| 8040 | Cal.com | Scheduling Platform | - |
| 8047 | Baserow | Airtable Alternative | [→ Setup Guide](docs/BASEROW_SETUP.md) |
| 8048 | NocoDB | Smart Spreadsheet | - |
| 8049 | Vikunja | Task Management | - |
| 8050 | Leantime | Project Management | - |

### Utilities (8060-8079)
| Port | Service | Description | Setup Guide |
|------|---------|-------------|-------------|
| 8060 | Postiz | Social Media Manager | [→ Providers Setup](docs/POSTIZ_PROVIDERS_SETUP.md) |
| 8061 | Vaultwarden | Password Manager | - |
| 8062 | Kopia | Backup System | - |

### Mail Services (8071 only - Learning/Testing)
| Port | Service | Description |
|------|---------|-------------|
| 8071 | Mailpit Web UI | Email catcher for development & testing |

**Note:** Mailpit captures ALL emails for learning purposes. No external email delivery.

### Specialized Services (8080-8099)
| Port | Service | Description | Setup Guide |
|------|---------|-------------|-------------|
| 8080 | Whisper | Speech-to-Text | - |
| 8081 | OpenedAI-Speech | Text-to-Speech | - |
| 8082 | LibreTranslate | Translation Service | - |
| 8083 | Scriberr | Audio Transcription | [→ Troubleshooting](docs/SCRIBERR_TROUBLESHOOTING.md) |
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
| Port | Service | Description | Setup Guide |
|------|---------|-------------|-------------|
| 8096 | Langfuse | LLM Performance Tracking | [→ Integration Guide](docs/LANGFUSE_OLLAMA_INTEGRATION.md) |
| 8097 | ClickHouse | Analytics Database | - |
| 8098 | MinIO | Object Storage | - |
| 8099 | MinIO Console | Storage Management | - |

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

## 🎯 Use Cases

This AI LaunchKit serves **multiple purposes** - from education to professional deployment. Here are practical scenarios for each service category:

### 💼 Professional Use Cases

**Team AI Infrastructure:**
- Deploy private AI services for your organization
- No data leaves your network
- Full control over models and data
- Comply with data protection regulations

**Development Environment:**
- Build and test AI applications locally
- Prototype before cloud deployment
- Debug workflows in safe environment
- Test different models and configurations

**Business Automation:**
- Automate internal processes with n8n
- Build custom AI tools for your team
- Create private knowledge bases with RAG
- Process documents without external APIs

### 🎓 Learning & Education Scenarios

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

## ℹ️ How Configuration Works (Reference)

⚠️ **IMPORTANT:** Everything is configured automatically during installation!
**You do NOT need to do anything here** - this section is just for reference.

<details>
<summary><b>📖 Click to see what the installation wizard configures automatically (Informational Only)</b></summary>

The installation wizard automatically handles all configuration:

### What Gets Configured Automatically:

**1. Environment File (.env)**
- ✅ Created from `.env.local.example` template
- ✅ All passwords generated automatically (32+ characters)
- ✅ All settings configured by wizard
- ✅ You never need to edit .env manually during installation

**2. Network Configuration**
- ✅ SERVER_IP auto-detected (e.g., 192.168.1.100)
- ✅ Wizard asks you to confirm the detected IP
- ✅ Automatically written to .env
- ✅ All services configured to use this IP

**3. Service Selection**
- ✅ Interactive checkbox menu in wizard
- ✅ Use arrow keys to navigate
- ✅ Spacebar to select/deselect
- ✅ Automatically written to COMPOSE_PROFILES in .env

**4. Ollama Hardware Selection**
- ✅ Choose CPU, NVIDIA GPU, or AMD GPU in wizard
- ✅ NVIDIA Container Toolkit installed automatically if GPU selected
- ✅ Automatically configured in .env

**5. Mail Configuration**
- ✅ Mailpit configured automatically
- ✅ All services configured to use Mailpit
- ✅ No external mail server needed

**6. Optional API Keys**
- ✅ Wizard asks if you want to add OpenAI, Anthropic, Groq keys
- ✅ Press Enter to skip (can add later)
- ✅ Automatically written to .env if provided

**After installation completes, everything is ready to use!**
No manual configuration needed.

</details>

---

## 🔧 Changing Configuration After Installation (Optional)

**Only use this section if you want to make changes after installation.**

<details>
<summary><b>📝 How to add or remove services</b></summary>

### When to use this:
- You want to try additional services (e.g., add ComfyUI, bolt.diy)
- You want to remove services you're not using
- You want to enable GPU after starting with CPU

### Step-by-Step:

1. **Stop all services:**
   ```bash
   cd ~/ai/ai-launchkit-local
   docker compose -p localai -f docker-compose.local.yml down
   ```
   - This stops all containers safely
   - Your data is preserved in volumes

2. **Open .env file:**
   ```bash
   nano .env
   ```
   - nano is a simple text editor
   - Press arrow keys to navigate

3. **Find the COMPOSE_PROFILES line:**
   ```bash
   COMPOSE_PROFILES="n8n,flowise,monitoring"
   ```
   - It's near the bottom of the file
   - Lists all active services

4. **Edit the services:**
   - Add services: `COMPOSE_PROFILES="n8n,flowise,monitoring,cpu,comfyui"`
   - Remove services: Delete the service name
   - Separate with commas (no spaces!)

   **Available services:**
   - AI: n8n, flowise, bolt, openui, comfyui, cpu, gpu-nvidia, open-webui
   - RAG: qdrant, weaviate, neo4j, lightrag, ragapp
   - Learning: calcom, baserow, nocodb, vikunja, leantime
   - Tools: vaultwarden, kopia, postiz, monitoring
   - Specialized: speech, ocr, libretranslate, stirling-pdf, searxng, perplexica

5. **Save and exit:**
   - Press `Ctrl+X`
   - Press `Y` (yes, save changes)
   - Press `Enter`

6. **Start services with new configuration:**
   ```bash
   docker compose -p localai -f docker-compose.local.yml up -d
   ```
   - Starts services with your new selection
   - Downloads new service images if needed
   - Takes 2-5 minutes

7. **Verify services are running:**
   ```bash
   docker ps
   ```
   - Lists all running containers
   - Check for your new services

8. **Access new services:**
   - Open browser: `http://SERVER-IP/`
   - Click on newly added services
   - May need to wait 1-2 minutes for initialization

</details>

<details>
<summary><b>🌐 How to change server IP address</b></summary>

### When to use this:
- Your server got a new IP address
- You want to access from different network
- You initially skipped LAN configuration

### Step-by-Step:

1. **Find your server's current IP:**
   ```bash
   ip addr show | grep 'inet ' | grep -v 127.0.0.1
   ```
   - Shows all network interfaces
   - Look for your LAN IP (e.g., 192.168.1.100)
   - Example output: `inet 192.168.1.100/24`

2. **Stop all services:**
   ```bash
   cd ~/ai/ai-launchkit-local
   docker compose -p localai -f docker-compose.local.yml down
   ```

3. **Edit .env file:**
   ```bash
   nano .env
   ```

4. **Find SERVER_IP line:**
   ```bash
   SERVER_IP=192.168.1.100
   ```
   - Usually near the bottom of the file

5. **Change to new IP:**
   ```bash
   SERVER_IP=192.168.1.200  # Your new IP
   ```

6. **Save and exit:**
   - Press `Ctrl+X`, then `Y`, then `Enter`

7. **Restart all services:**
   ```bash
   docker compose -p localai -f docker-compose.local.yml up -d
   ```

8. **Test access:**
   - Open browser: `http://NEW-IP:8000`
   - Services should load with new IP
   - Update bookmarks on your devices

</details>

<details>
<summary><b>🔑 How to add AI API keys</b></summary>

### When to use this:
- You skipped API keys during installation
- You got new API keys
- You want to use cloud AI services (OpenAI, Anthropic, Groq)

### Step-by-Step:

1. **Open .env file:**
   ```bash
   cd ~/ai/ai-launchkit-local
   nano .env
   ```

2. **Find the API key section:**
   ```bash
   # Optional AI API Keys
   OPENAI_API_KEY=
   ANTHROPIC_API_KEY=
   GROQ_API_KEY=
   ```

3. **Add your keys:**
   ```bash
   OPENAI_API_KEY=sk-your-key-here
   ANTHROPIC_API_KEY=sk-ant-your-key-here
   GROQ_API_KEY=gsk-your-key-here
   ```
   - Remove the trailing `=` and add your key
   - No quotes needed
   - Get keys from: OpenAI.com, Anthropic.com, Groq.com

4. **Save and exit:**
   - Press `Ctrl+X`, then `Y`, then `Enter`

5. **Restart affected services:**
   ```bash
   docker compose -p localai -f docker-compose.local.yml restart n8n flowise bolt
   ```
   - Only restarts services that use API keys
   - Faster than restarting everything

6. **Test API keys:**
   - Open n8n: `http://SERVER-IP:8000`
   - Create workflow with OpenAI node
   - API keys should work now

</details>

<details>
<summary><b>⚙️ How to change n8n worker count</b></summary>

### When to use this:
- System has more CPU cores
- Want to process workflows faster in parallel
- Currently have performance issues

### Step-by-Step:

1. **Check current CPU cores:**
   ```bash
   nproc
   ```
   - Shows number of CPU cores
   - Example output: `8`

2. **Edit .env file:**
   ```bash
   nano .env
   ```

3. **Find N8N_WORKER_COUNT:**
   ```bash
   N8N_WORKER_COUNT=1
   ```

4. **Change number:**
   ```bash
   N8N_WORKER_COUNT=4  # Use 4 workers
   ```
   - Recommendation: Use 50% of CPU cores
   - Don't exceed number of cores

5. **Save and exit:**
   - Press `Ctrl+X`, then `Y`, then `Enter`

6. **Restart n8n:**
   ```bash
   docker compose -p localai -f docker-compose.local.yml restart n8n-worker
   ```

7. **Verify workers:**
   ```bash
   docker ps | grep n8n-worker
   ```
   - Should show multiple n8n-worker containers
   - One per worker count

</details>

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

**Automatic Update (Recommended):**
```bash
# Run the update script
cd ai-launchkit-local
sudo bash ./scripts/update_local.sh
```

The update script will:
1. ✅ Create automatic backup of your configuration
2. ✅ Pull latest changes from GitHub
3. ✅ Update all Docker images
4. ✅ Restart services with new versions
5. ✅ Perform health checks
6. ✅ Provide rollback instructions if needed

**Manual Update:**
```bash
cd ai-launchkit-local

# Update repository
git pull origin main

# Update Docker images
docker compose -p localai -f docker-compose.local.yml pull

# Restart services
docker compose -p localai -f docker-compose.local.yml up -d

# Clean up old images
docker image prune -f
```

**What Gets Updated:**
- ✅ AI LaunchKit scripts and configurations
- ✅ Docker images for all services
- ✅ Landing page and templates
- ✅ Documentation

**What Gets Preserved:**
- ✅ Your .env configuration (automatically backed up and restored)
- ✅ All data in Docker volumes
- ✅ Service selections and settings

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
http://192.168.1.100/         # Service Dashboard
http://192.168.1.100:8000     # n8n interface
http://192.168.1.100:8071     # Email interface
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

[💬 Issues & Feature Requests](https://github.com/hermannheinrich/ai-launchkit-local/issues)

</div>
