#!/bin/bash

# Final installation report for local network deployment
# This script generates a comprehensive access guide for all services

set -e

# Source the utilities file
source "$(dirname "$0")/utils.sh"

# Load environment variables
if [ -f ".env" ]; then
    source .env
else
    log_error ".env file not found. Cannot generate report."
    exit 1
fi

# Get server IP for display
SERVER_IP="${SERVER_IP:-127.0.0.1}"

# Function to check if a service is running
is_service_running() {
    local service_name="$1"
    docker ps | grep -q "$service_name" && echo "🟢 RUNNING" || echo "🔴 STOPPED"
}

# Function to test port connectivity
test_port() {
    local port="$1"
    local service="$2"
    if nc -z localhost "$port" 2>/dev/null; then
        echo "✅ $service: http://$SERVER_IP:$port"
    else
        echo "❌ $service: Port $port not responding"
    fi
}

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                 🚀 AI LAUNCHKIT - LOCAL NETWORK                  ║"
echo "║                     Installation Complete!                       ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# System Information
log_info "📊 System Information"
echo "=========================================="
echo "Server IP Address: $SERVER_IP"
echo "Docker Project: localai"
echo "Docker Compose File: docker-compose.local.yml"
echo "Port Range: 8000-8099 (+ UDP 10000 for Jitsi)"
echo "Access Method: HTTP (no SSL required)"
echo "Authentication: Disabled for local network"
echo ""

# Core Services Status
log_info "🏗️ Core Services"
echo "=========================================="
echo "PostgreSQL Database: $(is_service_running "postgres")"
test_port 8001 "PostgreSQL"
echo "Redis Cache: $(is_service_running "redis")"
test_port 8002 "Redis"
echo "Mailpit Mail Catcher: $(is_service_running "mailpit")"
test_port 8071 "Mailpit Web UI"
echo ""

# AI Services Status  
log_info "🤖 AI Services"
echo "=========================================="
if [[ "$COMPOSE_PROFILES" == *"n8n"* ]]; then
    echo "n8n Workflow Automation: $(is_service_running "n8n")"
    test_port 8000 "n8n"
fi

if [[ "$COMPOSE_PROFILES" == *"flowise"* ]]; then
    echo "Flowise AI Agent Builder: $(is_service_running "flowise")"
    test_port 8022 "Flowise"
fi

if [[ "$COMPOSE_PROFILES" == *"open-webui"* ]]; then
    echo "Open WebUI ChatGPT Interface: $(is_service_running "open-webui")"
    test_port 8020 "Open WebUI"
fi

if [[ "$COMPOSE_PROFILES" == *"cpu"* ]] || [[ "$COMPOSE_PROFILES" == *"gpu-nvidia"* ]] || [[ "$COMPOSE_PROFILES" == *"gpu-amd"* ]]; then
    echo "Ollama Local LLM Runtime: $(is_service_running "ollama")"
    test_port 8021 "Ollama API"
fi

if [[ "$COMPOSE_PROFILES" == *"bolt"* ]]; then
    echo "bolt.diy AI Web Development: $(is_service_running "bolt")"
    test_port 8023 "bolt.diy"
fi

if [[ "$COMPOSE_PROFILES" == *"comfyui"* ]]; then
    echo "ComfyUI Stable Diffusion: $(is_service_running "comfyui")"
    test_port 8024 "ComfyUI"
fi

if [[ "$COMPOSE_PROFILES" == *"openui"* ]]; then
    echo "OpenUI AI Component Generator: $(is_service_running "openui")"
    test_port 8025 "OpenUI"
fi

# Vector Databases
if [[ "$COMPOSE_PROFILES" == *"qdrant"* ]]; then
    echo "Qdrant Vector Database: $(is_service_running "qdrant")"
    test_port 8026 "Qdrant"
fi

if [[ "$COMPOSE_PROFILES" == *"weaviate"* ]]; then
    echo "Weaviate Vector Database: $(is_service_running "weaviate")"
    test_port 8027 "Weaviate"
fi

if [[ "$COMPOSE_PROFILES" == *"neo4j"* ]]; then
    echo "Neo4j Graph Database: $(is_service_running "neo4j")"
    test_port 8028 "Neo4j Browser"
fi

if [[ "$COMPOSE_PROFILES" == *"lightrag"* ]]; then
    echo "LightRAG Graph-based RAG: $(is_service_running "lightrag")"
    test_port 8029 "LightRAG"
fi

if [[ "$COMPOSE_PROFILES" == *"ragapp"* ]]; then
    echo "RAGApp Open-source RAG UI: $(is_service_running "ragapp")"
    test_port 8030 "RAGApp"
fi

echo ""

# Business Tools Status
log_info "💼 Business Tools"
echo "=========================================="
if [[ "$COMPOSE_PROFILES" == *"calcom"* ]]; then
    echo "Cal.com Scheduling Platform: $(is_service_running "calcom")"
    test_port 8040 "Cal.com"
fi

if [[ "$COMPOSE_PROFILES" == *"odoo"* ]]; then
    echo "Odoo ERP/CRM: $(is_service_running "odoo")"
    test_port 8041 "Odoo"
fi

if [[ "$COMPOSE_PROFILES" == *"kimai"* ]]; then
    echo "Kimai Time Tracking: $(is_service_running "kimai")"
    test_port 8042 "Kimai"
fi

if [[ "$COMPOSE_PROFILES" == *"invoiceninja"* ]]; then
    echo "Invoice Ninja Invoicing: $(is_service_running "invoiceninja_nginx")"
    test_port 8043 "Invoice Ninja"
fi

if [[ "$COMPOSE_PROFILES" == *"twenty-crm"* ]]; then
    echo "Twenty CRM: $(is_service_running "twenty-crm")"
    test_port 8044 "Twenty CRM"
fi

if [[ "$COMPOSE_PROFILES" == *"espocrm"* ]]; then
    echo "EspoCRM: $(is_service_running "espocrm")"
    test_port 8045 "EspoCRM"
fi

if [[ "$COMPOSE_PROFILES" == *"mautic"* ]]; then
    echo "Mautic Marketing Automation: $(is_service_running "mautic_web")"
    test_port 8046 "Mautic"
fi

if [[ "$COMPOSE_PROFILES" == *"baserow"* ]]; then
    echo "Baserow Database: $(is_service_running "baserow")"
    test_port 8047 "Baserow"
fi

if [[ "$COMPOSE_PROFILES" == *"nocodb"* ]]; then
    echo "NocoDB Smart Spreadsheet: $(is_service_running "nocodb")"
    test_port 8048 "NocoDB"
fi

if [[ "$COMPOSE_PROFILES" == *"vikunja"* ]]; then
    echo "Vikunja Task Management: $(is_service_running "vikunja")"
    test_port 8049 "Vikunja"
fi

if [[ "$COMPOSE_PROFILES" == *"leantime"* ]]; then
    echo "Leantime Project Management: $(is_service_running "leantime")"
    test_port 8050 "Leantime"
fi

echo ""

# Communication & Utilities
log_info "🔧 Utilities & Communication"
echo "=========================================="
if [[ "$COMPOSE_PROFILES" == *"jitsi"* ]]; then
    echo "Jitsi Meet Video Conferencing: $(is_service_running "jitsi-web")"
    test_port 8051 "Jitsi Meet"
    echo "  ⚠️ UDP Port 10000 required for audio/video"
fi

if [[ "$COMPOSE_PROFILES" == *"postiz"* ]]; then
    echo "Postiz Social Media Manager: $(is_service_running "postiz")"
    test_port 8060 "Postiz"
fi

if [[ "$COMPOSE_PROFILES" == *"vaultwarden"* ]]; then
    echo "Vaultwarden Password Manager: $(is_service_running "vaultwarden")"
    test_port 8061 "Vaultwarden"
fi

if [[ "$COMPOSE_PROFILES" == *"kopia"* ]]; then
    echo "Kopia Backup System: $(is_service_running "kopia")"
    test_port 8062 "Kopia"
fi

echo ""

# Monitoring & Administration
if [[ "$COMPOSE_PROFILES" == *"monitoring"* ]]; then
    log_info "📊 Monitoring & Administration"
    echo "=========================================="
    echo "Grafana Dashboards: $(is_service_running "grafana")"
    test_port 8003 "Grafana"
    echo "Prometheus Metrics: $(is_service_running "prometheus")"
    test_port 8004 "Prometheus"
    echo "Node Exporter: $(is_service_running "node-exporter")"
    test_port 8005 "Node Exporter"
    echo "cAdvisor Container Monitoring: $(is_service_running "cadvisor")"
    test_port 8006 "cAdvisor"
fi

if [[ "$COMPOSE_PROFILES" == *"portainer"* ]]; then
    echo "Portainer Docker Management: $(is_service_running "portainer")"
    test_port 8007 "Portainer"
fi

echo ""

# Specialized Services
log_info "🔧 Specialized Services"
echo "=========================================="
if [[ "$COMPOSE_PROFILES" == *"speech"* ]]; then
    echo "Faster-Whisper Speech-to-Text: $(is_service_running "faster-whisper")"
    test_port 8080 "Whisper STT"
    echo "OpenedAI Speech Text-to-Speech: $(is_service_running "openedai-speech")"
    test_port 8081 "OpenedAI TTS"
fi

if [[ "$COMPOSE_PROFILES" == *"libretranslate"* ]]; then
    echo "LibreTranslate Translation: $(is_service_running "libretranslate")"
    test_port 8082 "LibreTranslate"
fi

if [[ "$COMPOSE_PROFILES" == *"scriberr"* ]]; then
    echo "Scriberr Audio Transcription: $(is_service_running "scriberr")"
    test_port 8083 "Scriberr"
fi

if [[ "$COMPOSE_PROFILES" == *"ocr"* ]]; then
    echo "Tesseract OCR: $(is_service_running "tesseract-ocr")"
    test_port 8084 "Tesseract OCR"
    echo "EasyOCR: $(is_service_running "easyocr")"
    test_port 8085 "EasyOCR"
fi

if [[ "$COMPOSE_PROFILES" == *"stirling-pdf"* ]]; then
    echo "Stirling-PDF Tools: $(is_service_running "stirling-pdf")"
    test_port 8086 "Stirling-PDF"
fi

if [[ "$COMPOSE_PROFILES" == *"tts-chatterbox"* ]]; then
    echo "Chatterbox TTS API: $(is_service_running "chatterbox-tts")"
    test_port 8087 "Chatterbox API"
    echo "Chatterbox Web UI: $(is_service_running "chatterbox-frontend")"
    test_port 8088 "Chatterbox Web UI"
fi

if [[ "$COMPOSE_PROFILES" == *"searxng"* ]]; then
    echo "SearXNG Search Engine: $(is_service_running "searxng")"
    test_port 8089 "SearXNG"
fi

if [[ "$COMPOSE_PROFILES" == *"perplexica"* ]]; then
    echo "Perplexica AI Search: $(is_service_running "perplexica")"
    test_port 8090 "Perplexica"
fi

if [[ "$COMPOSE_PROFILES" == *"formbricks"* ]]; then
    echo "Formbricks Surveys: $(is_service_running "formbricks")"
    test_port 8091 "Formbricks"
fi

if [[ "$COMPOSE_PROFILES" == *"metabase"* ]]; then
    echo "Metabase Business Intelligence: $(is_service_running "metabase")"
    test_port 8092 "Metabase"
fi

if [[ "$COMPOSE_PROFILES" == *"crawl4ai"* ]]; then
    echo "Crawl4AI Web Crawler: $(is_service_running "crawl4ai")"
    test_port 8093 "Crawl4AI"
fi

if [[ "$COMPOSE_PROFILES" == *"gotenberg"* ]]; then
    echo "Gotenberg Document Conversion: $(is_service_running "gotenberg")"
    test_port 8094 "Gotenberg"
fi

if [[ "$COMPOSE_PROFILES" == *"python-runner"* ]]; then
    echo "Python Runner: $(is_service_running "python-runner")"
    test_port 8095 "Python Runner"
fi

echo ""

# Langfuse Stack
if [[ "$COMPOSE_PROFILES" == *"langfuse"* ]]; then
    log_info "📈 Langfuse AI Observability Stack"
    echo "=========================================="
    echo "Langfuse Web Interface: $(is_service_running "langfuse-web")"
    test_port 8096 "Langfuse"
    echo "ClickHouse Analytics: $(is_service_running "clickhouse")"
    test_port 8097 "ClickHouse"
    echo "MinIO Object Storage: $(is_service_running "minio")"
    test_port 8098 "MinIO API"
    test_port 8099 "MinIO Console"
    echo ""
fi

# External Repositories Status
if [[ "$COMPOSE_PROFILES" == *"supabase"* ]]; then
    log_info "📦 External Repository Services"
    echo "=========================================="
    echo "Supabase Backend-as-a-Service: $(is_service_running "kong")"
    echo "  ➡️ Access: http://$SERVER_IP:8100"
    if ! docker ps | grep -q "kong"; then
        echo "  ❌ Kong Gateway not running - check Supabase setup"
    fi
fi

if [[ "$COMPOSE_PROFILES" == *"dify"* ]]; then
    echo "Dify AI Application Platform:"
    echo "  ➡️ Access: http://$SERVER_IP:8101"
    if ! nc -z localhost 8101 2>/dev/null; then
        echo "  ❌ Port 8101 not responding - check Dify setup"
    fi
fi

echo ""

# Credentials and Important Information
log_info "🔐 Important Access Information"
echo "=========================================="

# Database credentials
echo "📊 Database Access:"
echo "  PostgreSQL: $SERVER_IP:8001"
echo "  Username: postgres"
echo "  Password: [Check .env file: POSTGRES_PASSWORD]"
echo ""

# Key service credentials
echo "🔑 Service Credentials:"

if [[ "$COMPOSE_PROFILES" == *"grafana"* ]]; then
    echo "  Grafana Admin: admin / [Check .env: GRAFANA_ADMIN_PASSWORD]"
fi

if [[ "$COMPOSE_PROFILES" == *"flowise"* ]]; then
    echo "  Flowise: admin@localhost / [Check .env: FLOWISE_PASSWORD]"
fi

if [[ "$COMPOSE_PROFILES" == *"vaultwarden"* ]]; then
    echo "  Vaultwarden Admin: [Check .env: VAULTWARDEN_ADMIN_TOKEN]"
fi

if [[ "$COMPOSE_PROFILES" == *"odoo"* ]]; then
    echo "  Odoo Admin: admin@localhost / [Check .env: ODOO_PASSWORD]"
fi

echo ""

# Network Configuration Help
log_info "🌐 Network Access Configuration"
echo "=========================================="
echo "Current SERVER_IP: $SERVER_IP"
echo ""
echo "To access from other devices in your local network:"
echo ""
echo "1. Find your server's LAN IP address:"
echo "   ip addr show | grep 'inet ' | grep -v 127.0.0.1"
echo "   # Example output: 192.168.1.100"
echo ""
echo "2. Update the SERVER_IP in .env file:"
echo "   sed -i 's/SERVER_IP=127.0.0.1/SERVER_IP=192.168.1.100/' .env"
echo ""
echo "3. Restart services to apply changes:"
echo "   docker compose -p localai -f docker-compose.local.yml restart"
echo ""
echo "4. Access from any device on your network:"
echo "   http://192.168.1.100:8000 (n8n)"
echo "   http://192.168.1.100:8022 (Flowise)"
echo "   http://192.168.1.100:8003 (Grafana)"
echo "   etc."
echo ""

# Firewall Configuration
log_info "🔥 Firewall Configuration"
echo "=========================================="
echo "Current firewall status:"
ufw status | head -10
echo ""
echo "To allow access from local network (if needed):"
echo "  sudo ufw allow from 192.168.1.0/24 to any port 8000:8099"
echo "  sudo ufw allow from 10.0.0.0/8 to any port 8000:8099"
echo "  sudo ufw reload"
echo ""

# Useful Commands
log_info "🛠️ Useful Commands"
echo "=========================================="
echo "Start all services:"
echo "  docker compose -p localai -f docker-compose.local.yml up -d"
echo ""
echo "Stop all services:"
echo "  docker compose -p localai -f docker-compose.local.yml down"
echo ""
echo "View service logs:"
echo "  docker compose -p localai -f docker-compose.local.yml logs [service_name]"
echo ""
echo "Check running services:"
echo "  docker ps"
echo ""
echo "Monitor resource usage:"
echo "  docker stats"
echo ""
echo "Update all services:"
echo "  docker compose -p localai -f docker-compose.local.yml pull"
echo "  docker compose -p localai -f docker-compose.local.yml up -d"
echo ""

# Service-specific information
if [[ "$COMPOSE_PROFILES" == *"jitsi"* ]]; then
    log_info "📹 Jitsi Meet Video Conferencing"
    echo "=========================================="
    echo "⚠️ IMPORTANT: Jitsi requires UDP port 10000 for audio/video"
    echo ""
    echo "Test UDP connectivity:"
    echo "  # Terminal 1 (on server):"
    echo "  nc -u -l 10000"
    echo ""
    echo "  # Terminal 2 (from client):"
    echo "  nc -u $SERVER_IP 10000"
    echo ""
    echo "Create meeting rooms:"
    echo "  http://$SERVER_IP:8051/your-room-name"
    echo ""
fi

if [[ "$COMPOSE_PROFILES" == *"n8n"* ]]; then
    log_info "⚙️ n8n Workflow Automation"
    echo "=========================================="
    echo "First login: Create admin account at http://$SERVER_IP:8000"
    echo ""
    if [[ "$RUN_N8N_IMPORT" == "true" ]]; then
        echo "📦 300+ workflows are being imported..."
        echo "This may take 20-30 minutes to complete"
        echo "Check import progress: docker logs n8n-import"
    fi
    echo ""
fi

# Final Success Message
echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                    🎉 INSTALLATION SUCCESSFUL!                   ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
log_success "AI LaunchKit is now running on your local network!"
echo ""
log_info "📖 Documentation:"
log_info "  - Local README: README.local.md"
log_info "  - Original docs: README.md"
log_info "  - Configuration: .env"
echo ""
log_info "🆘 Support:"
log_info "  - GitHub Issues: https://github.com/hermannheinrich/ai-launchkit-local/issues"
log_info "  - Original Project: https://github.com/freddy-schuetz/ai-launchkit"
echo ""
log_info "🔧 Maintenance:"
log_info "  - Check service status: docker ps"
log_info "  - View logs: docker compose -p localai -f docker-compose.local.yml logs"
log_info "  - Update services: docker compose -p localai -f docker-compose.local.yml pull"
echo ""

# Save access URLs to a file for easy reference
cat > "LOCAL_ACCESS_URLS.txt" << EOF
# AI LaunchKit - Local Network Access URLs
# Generated: $(date)
# Server IP: $SERVER_IP

# Core Services:
n8n Workflow Automation: http://$SERVER_IP:8000
PostgreSQL Database: $SERVER_IP:8001
Redis Cache: $SERVER_IP:8002
Grafana Monitoring: http://$SERVER_IP:8003
Prometheus Metrics: http://$SERVER_IP:8004

# Mail System:
Mailpit Email Catcher: http://$SERVER_IP:8071

# AI Services:
$([ "$COMPOSE_PROFILES" == *"open-webui"* ] && echo "Open WebUI: http://$SERVER_IP:8020")
$([ "$COMPOSE_PROFILES" == *"ollama"* ] && echo "Ollama API: http://$SERVER_IP:8021")
$([ "$COMPOSE_PROFILES" == *"flowise"* ] && echo "Flowise: http://$SERVER_IP:8022")
$([ "$COMPOSE_PROFILES" == *"bolt"* ] && echo "bolt.diy: http://$SERVER_IP:8023")
$([ "$COMPOSE_PROFILES" == *"comfyui"* ] && echo "ComfyUI: http://$SERVER_IP:8024")

# Business Tools:
$([ "$COMPOSE_PROFILES" == *"calcom"* ] && echo "Cal.com: http://$SERVER_IP:8040")
$([ "$COMPOSE_PROFILES" == *"odoo"* ] && echo "Odoo: http://$SERVER_IP:8041")
$([ "$COMPOSE_PROFILES" == *"kimai"* ] && echo "Kimai: http://$SERVER_IP:8042")
$([ "$COMPOSE_PROFILES" == *"invoiceninja"* ] && echo "Invoice Ninja: http://$SERVER_IP:8043")

# Change SERVER_IP=127.0.0.1 to your server's LAN IP in .env for network access
EOF

log_success "Access URLs saved to: LOCAL_ACCESS_URLS.txt"

echo ""
log_info "🚀 Your AI LaunchKit is ready!"
log_info "Change SERVER_IP in .env to enable network access from other devices."

exit 0
