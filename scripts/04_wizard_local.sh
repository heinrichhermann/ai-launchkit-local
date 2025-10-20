#!/bin/bash

# Local Network Service Selection Wizard - No Domain Configuration Needed

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"

# Source the utilities file
source "$(dirname "$0")/utils.sh"

# Function to check if whiptail is installed
check_whiptail() {
    if ! command -v whiptail &> /dev/null; then
        log_error "'whiptail' is not installed."
        log_info "This tool is required for the interactive service selection."
        log_info "On Debian/Ubuntu, you can install it using: sudo apt-get install whiptail"
        log_info "Please install whiptail and try again."
        exit 1
    fi
}

# Call the check
check_whiptail

# Store original DEBIAN_FRONTEND and set to dialog for whiptail
ORIGINAL_DEBIAN_FRONTEND="$DEBIAN_FRONTEND"
export DEBIAN_FRONTEND=dialog

# --- Read current COMPOSE_PROFILES from .env ---
CURRENT_PROFILES_VALUE=""
if [ -f "$ENV_FILE" ]; then
    LINE_CONTENT=$(grep "^COMPOSE_PROFILES=" "$ENV_FILE" || echo "")
    if [ -n "$LINE_CONTENT" ]; then
        CURRENT_PROFILES_VALUE=$(echo "$LINE_CONTENT" | cut -d'=' -f2- | sed 's/^"//' | sed 's/"$//')
    fi
fi
current_profiles_for_matching=",$CURRENT_PROFILES_VALUE,"

# Define available services for local network deployment
base_services_data=(
    "n8n" "n8n, n8n-worker, n8n-import (Workflow Automation) - Port 8000"
    "flowise" "Flowise (AI Agent Builder) - Port 8022"
    "bolt" "bolt.diy (AI Web Development) - Port 8023"
    "openui" "OpenUI (AI Frontend/UI Generator) - Port 8025"
    "monitoring" "Monitoring Suite (Prometheus: 8004, Grafana: 8003)"
    "portainer" "Portainer (Docker Management UI) - Port 8007"
    "postiz" "Postiz (Social Publishing Platform) - Port 8060"
    "baserow" "Baserow (Airtable Alternative) - Port 8047"
    "nocodb" "NocoDB (Smart Spreadsheet UI) - Port 8048"
    "vikunja" "Vikunja (Task Management) - Port 8049"
    "leantime" "Leantime (Project Management) - Port 8050"
    "calcom" "Cal.com (Open Source Scheduling) - Port 8040"
    "formbricks" "Formbricks (Privacy-first Surveys) - Port 8091"
    "metabase" "Metabase (Business Intelligence) - Port 8092"
    "vaultwarden" "Vaultwarden (Password Manager) - Port 8061"
    "kopia" "Kopia (Fast Secure Backup) - Port 8062"
    "langfuse" "Langfuse Suite (AI Observability) - Port 8096"
    "qdrant" "Qdrant (Vector Database) - Port 8026"
    "weaviate" "Weaviate (Vector Database API) - Port 8027"
    "lightrag" "LightRAG (Graph-based RAG) - Port 8029"
    "neo4j" "Neo4j (Graph Database) - Port 8028"
    "letta" "Letta (Agent Server & SDK) - Port 8031"
    "gotenberg" "Gotenberg (Document Conversion API) - Port 8094"
    "stirling-pdf" "Stirling-PDF (100+ PDF Tools) - Port 8086"
    "crawl4ai" "Crawl4ai (Web Crawler for AI) - Port 8093"
    "ragapp" "RAGApp (Open-source RAG UI) - Port 8030"
    "open-notebook" "Open Notebook (NotebookLM Alternative) - Ports 8100, 8101"
    "open-webui" "Open WebUI (ChatGPT-like Interface) - Port 8020"
    "searxng" "SearXNG (Private Metasearch Engine) - Port 8089"
    "perplexica" "Perplexica (AI-powered Search Engine) - Port 8090"
    "python-runner" "Python Runner (Custom Python Code) - Port 8095"
    "ollama" "Ollama (Local LLM Runner - select hardware next)"
    "comfyui" "ComfyUI (Node-based Stable Diffusion) - Port 8024"
    "speech" "Speech Stack (Whisper ASR + TTS) - Ports 8080, 8081"
    "tts-chatterbox" "TTS Chatterbox (Advanced TTS) - Ports 8087, 8088"
    "scriberr" "Scriberr (AI Audio Transcription) - Port 8083"
    "ocr" "OCR Bundle (Tesseract + EasyOCR) - Ports 8084, 8085"
    "libretranslate" "LibreTranslate (Self-hosted Translation) - Port 8082"
)

services=()

# Populate services array for whiptail
idx=0
while [ $idx -lt ${#base_services_data[@]} ]; do
    tag="${base_services_data[idx]}"
    description="${base_services_data[idx+1]}"
    status="OFF"

    if [ -n "$CURRENT_PROFILES_VALUE" ] && [ "$CURRENT_PROFILES_VALUE" != '""' ]; then
        if [[ "$tag" == "ollama" ]]; then
            if [[ "$current_profiles_for_matching" == *",cpu,"* || \
                  "$current_profiles_for_matching" == *",gpu-nvidia,"* || \
                  "$current_profiles_for_matching" == *",gpu-amd,"* ]]; then
                status="ON"
            fi
        elif [[ "$current_profiles_for_matching" == *",$tag,"* ]]; then
            status="ON"
        fi
    else
        # Default services for local network
        case "$tag" in
            "n8n"|"flowise"|"monitoring") status="ON" ;;
            *) status="OFF" ;;
        esac
    fi
    services+=("$tag" "$description" "$status")
    idx=$((idx + 2))
done

# Calculate dynamic dimensions for whiptail dialog
num_services=$(( ${#services[@]} / 3 ))
list_height=$num_services
if [ $list_height -gt 20 ]; then
    list_height=20
fi
window_height=$(( list_height + 10 ))

# Display service selection dialog
CHOICES=$(whiptail --title "AI LaunchKit - Local Network Service Selection" --checklist \
  "Choose services for your local network AI development stack.\n\nAll services will be accessible via http://SERVER_IP:PORT\nNo domain configuration or SSL certificates needed!\n\nUse ARROW KEYS to navigate, SPACEBAR to select, ENTER to confirm." $window_height 120 $list_height \
  "${services[@]}" \
  3>&1 1>&2 2>&3)

# Restore original DEBIAN_FRONTEND
if [ -n "$ORIGINAL_DEBIAN_FRONTEND" ]; then
  export DEBIAN_FRONTEND="$ORIGINAL_DEBIAN_FRONTEND"
else
  unset DEBIAN_FRONTEND
fi

# Handle user cancellation
exitstatus=$?
if [ $exitstatus -ne 0 ]; then
    log_info "Service selection cancelled by user. Using default services."
    if [ ! -f "$ENV_FILE" ]; then
        touch "$ENV_FILE"
    fi
    if grep -q "^COMPOSE_PROFILES=" "$ENV_FILE"; then
        sed -i.bak "/^COMPOSE_PROFILES=/d" "$ENV_FILE"
    fi
    echo "COMPOSE_PROFILES=n8n,flowise,monitoring" >> "$ENV_FILE"
    exit 0
fi

# Process selected services
selected_profiles=()
ollama_selected=0
scriberr_selected=0
ollama_profile=""

if [ -n "$CHOICES" ]; then
    temp_choices=()
    eval "temp_choices=($CHOICES)"

    for choice in "${temp_choices[@]}"; do
        if [ "$choice" == "ollama" ]; then
            ollama_selected=1
        elif [ "$choice" == "scriberr" ]; then
            scriberr_selected=1
        else
            selected_profiles+=("$choice")
        fi
    done
fi

# Handle Ollama hardware selection
if [ $ollama_selected -eq 1 ]; then
    default_ollama_hardware="cpu"
    ollama_hw_on_cpu="OFF"
    ollama_hw_on_gpu_nvidia="OFF"
    ollama_hw_on_gpu_amd="OFF"

    if [[ "$current_profiles_for_matching" == *",cpu,"* ]]; then
        ollama_hw_on_cpu="ON"
        default_ollama_hardware="cpu"
    elif [[ "$current_profiles_for_matching" == *",gpu-nvidia,"* ]]; then
        ollama_hw_on_gpu_nvidia="ON"
        default_ollama_hardware="gpu-nvidia"
    elif [[ "$current_profiles_for_matching" == *",gpu-amd,"* ]]; then
        ollama_hw_on_gpu_amd="ON"
        default_ollama_hardware="gpu-amd"
    else
        ollama_hw_on_cpu="ON"
        default_ollama_hardware="cpu"
    fi

    ollama_hardware_options=(
        "cpu" "CPU (Recommended for most users) - Port 8021" "$ollama_hw_on_cpu"
        "gpu-nvidia" "NVIDIA GPU (Requires NVIDIA drivers) - Port 8021" "$ollama_hw_on_gpu_nvidia"
        "gpu-amd" "AMD GPU (Requires ROCm drivers) - Port 8021" "$ollama_hw_on_gpu_amd"
    )
    
    CHOSEN_OLLAMA_PROFILE=$(whiptail --title "Ollama Hardware Profile" --default-item "$default_ollama_hardware" --radiolist \
      "Choose the hardware profile for Ollama local LLM runtime." 15 85 3 \
      "${ollama_hardware_options[@]}" \
      3>&1 1>&2 2>&3)

    ollama_exitstatus=$?
    if [ $ollama_exitstatus -eq 0 ] && [ -n "$CHOSEN_OLLAMA_PROFILE" ]; then
        selected_profiles+=("$CHOSEN_OLLAMA_PROFILE")
        ollama_profile="$CHOSEN_OLLAMA_PROFILE"
        log_info "Ollama hardware profile selected: $CHOSEN_OLLAMA_PROFILE"
    else
        log_info "Ollama hardware profile selection cancelled."
        ollama_selected=0
    fi
fi

# Handle Scriberr hardware selection (intelligently based on Ollama choice)
if [ $scriberr_selected -eq 1 ]; then
    if [ "$ollama_profile" == "gpu-nvidia" ]; then
        # User chose GPU for Ollama, enable GPU Scriberr automatically
        # Do NOT add "scriberr" to avoid conflict with "gpu-nvidia"
        log_info "Scriberr will use GPU acceleration (gpu-nvidia profile)"
    else
        # User chose CPU or AMD GPU, use CPU Scriberr
        selected_profiles+=("scriberr")
        log_info "Scriberr will use CPU (scriberr profile)"
    fi
fi

# Auto-enable MySQL when Leantime is selected
if [[ " ${selected_profiles[@]} " =~ " leantime " ]]; then
    if [[ ! " ${selected_profiles[@]} " =~ " mysql " ]]; then
        selected_profiles+=("mysql")
        echo
        log_info "📦 MySQL 8.4 will be installed automatically for Leantime"
        log_info "   You can use this MySQL instance for other services too"
        sleep 2
    fi
fi

# Display selected services
if [ ${#selected_profiles[@]} -eq 0 ]; then
    log_info "No optional services selected. Only core services will run."
    COMPOSE_PROFILES_VALUE=""
else
    log_info "Selected services for local network deployment:"
    COMPOSE_PROFILES_VALUE=$(IFS=,; echo "${selected_profiles[*]}")
    for profile in "${selected_profiles[@]}"; do
        if [[ "$profile" == "cpu" || "$profile" == "gpu-nvidia" || "$profile" == "gpu-amd" ]]; then
            if [ "$profile" == "$ollama_profile" ]; then
                 echo "  - Ollama ($profile profile) - Port 8021"
            else
                 echo "  - $profile"
            fi
        else
            echo "  - $profile"
        fi
    done
fi

# Create or update .env file
if [ ! -f "$ENV_FILE" ]; then
    log_warning "'.env' file not found. Creating from template..."
    if [ -f "$PROJECT_ROOT/.env.local.example" ]; then
        cp "$PROJECT_ROOT/.env.local.example" "$ENV_FILE"
    else
        touch "$ENV_FILE"
    fi
fi

# Update COMPOSE_PROFILES
if grep -q "^COMPOSE_PROFILES=" "$ENV_FILE"; then
    sed -i.bak "\|^COMPOSE_PROFILES=|d" "$ENV_FILE"
fi

echo "COMPOSE_PROFILES=${COMPOSE_PROFILES_VALUE}" >> "$ENV_FILE"

if [ -z "$COMPOSE_PROFILES_VALUE" ]; then
    log_info "Only core services (PostgreSQL, Redis, Mailpit) will be started."
else
    log_info "Docker Compose profiles configured: ${COMPOSE_PROFILES_VALUE}"
fi

# NO Cloudflare Tunnel needed for local network
log_info "Skipping Cloudflare Tunnel setup (not needed for local network)"

# NO SSL/Domain certificates needed
log_info "Skipping SSL certificate setup (HTTP-only for local network)"

# Local network mail configuration
log_info ""
log_info "📧 Mail System Configuration for Local Network"
log_info "============================================="
log_info "Mailpit will capture all emails from services"
log_info "Access mail interface at: http://SERVER_IP:8071"
log_info "No external mail delivery configured"

# Configure mail settings for local network
sed -i.bak "/^MAIL_MODE=/d" "$ENV_FILE"
sed -i.bak "/^SMTP_HOST=/d" "$ENV_FILE"
sed -i.bak "/^SMTP_PORT=/d" "$ENV_FILE"
sed -i.bak "/^SMTP_USER=/d" "$ENV_FILE"
sed -i.bak "/^SMTP_PASS=/d" "$ENV_FILE"
sed -i.bak "/^SMTP_FROM=/d" "$ENV_FILE"
sed -i.bak "/^SMTP_SECURE=/d" "$ENV_FILE"

echo "MAIL_MODE=mailpit" >> "$ENV_FILE"
echo "SMTP_HOST=mailpit" >> "$ENV_FILE"
echo "SMTP_PORT=1025" >> "$ENV_FILE"
echo "SMTP_USER=admin" >> "$ENV_FILE"
echo "SMTP_PASS=admin" >> "$ENV_FILE"
echo "SMTP_FROM=noreply@localhost" >> "$ENV_FILE"
echo "SMTP_SECURE=false" >> "$ENV_FILE"

# Mirror SMTP settings to EMAIL_* variables
echo "EMAIL_SMTP_HOST=mailpit" >> "$ENV_FILE"
echo "EMAIL_SMTP_PORT=1025" >> "$ENV_FILE"
echo "EMAIL_SMTP_USER=admin" >> "$ENV_FILE"
echo "EMAIL_SMTP_PASSWORD=admin" >> "$ENV_FILE"
echo "EMAIL_FROM=noreply@localhost" >> "$ENV_FILE"
echo "EMAIL_SMTP_USE_TLS=false" >> "$ENV_FILE"

log_success "Mail system configured for local network"

# Optional API keys configuration
echo ""
log_info "🔑 Optional: AI API Keys"
log_info "========================"
log_info "You can add API keys now or later by editing the .env file"

# Check existing API keys
existing_openai_key=""
existing_anthropic_key=""
existing_groq_key=""

if grep -q "^OPENAI_API_KEY=" "$ENV_FILE"; then
    existing_openai_key=$(grep "^OPENAI_API_KEY=" "$ENV_FILE" | cut -d'=' -f2- | sed 's/^\"//' | sed 's/\"$//')
fi

if grep -q "^ANTHROPIC_API_KEY=" "$ENV_FILE"; then
    existing_anthropic_key=$(grep "^ANTHROPIC_API_KEY=" "$ENV_FILE" | cut -d'=' -f2- | sed 's/^\"//' | sed 's/\"$//')
fi

if grep -q "^GROQ_API_KEY=" "$ENV_FILE"; then
    existing_groq_key=$(grep "^GROQ_API_KEY=" "$ENV_FILE" | cut -d'=' -f2- | sed 's/^\"//' | sed 's/\"$//')
fi

# Prompt for API keys if not already set
if [ -z "$existing_openai_key" ]; then
    echo ""
    log_info "OpenAI API Key (optional - for enhanced AI features):"
    log_info "Used by: bolt.diy, n8n, Supabase SQL assistant"
    read -p "OpenAI API Key (press Enter to skip): " input_openai_key
    if [ -n "$input_openai_key" ]; then
        sed -i.bak "/^OPENAI_API_KEY=/d" "$ENV_FILE"
        echo "OPENAI_API_KEY=$input_openai_key" >> "$ENV_FILE"
        log_success "OpenAI API key configured"
    fi
else
    log_info "OpenAI API key already configured"
fi

if [ -z "$existing_anthropic_key" ]; then
    echo ""
    log_info "Anthropic API Key (optional - for Claude models):"
    log_info "Used by: bolt.diy for advanced code generation"
    read -p "Anthropic API Key (press Enter to skip): " input_anthropic_key
    if [ -n "$input_anthropic_key" ]; then
        sed -i.bak "/^ANTHROPIC_API_KEY=/d" "$ENV_FILE"
        echo "ANTHROPIC_API_KEY=$input_anthropic_key" >> "$ENV_FILE"
        log_success "Anthropic API key configured"
    fi
else
    log_info "Anthropic API key already configured"
fi

if [ -z "$existing_groq_key" ]; then
    echo ""
    log_info "Groq API Key (optional - for fast inference):"
    log_info "Used by: bolt.diy for rapid prototyping"
    read -p "Groq API Key (press Enter to skip): " input_groq_key
    if [ -n "$input_groq_key" ]; then
        sed -i.bak "/^GROQ_API_KEY=/d" "$ENV_FILE"
        echo "GROQ_API_KEY=$input_groq_key" >> "$ENV_FILE"
        log_success "Groq API key configured"
    fi
else
    log_info "Groq API key already configured"
fi

# NO Google Calendar setup needed for local network
# (User can configure manually after installation if needed)

# Admin Credentials Configuration for services that need it
NEEDS_ADMIN_CREDENTIALS=false

if [[ "$COMPOSE_PROFILES_VALUE" == *"langfuse"* ]] || [[ "$COMPOSE_PROFILES_VALUE" == *"monitoring"* ]]; then
    NEEDS_ADMIN_CREDENTIALS=true
fi

if [ "$NEEDS_ADMIN_CREDENTIALS" = true ]; then
    echo ""
    log_info "🔐 Admin Credentials Configuration"
    log_info "===================================="
    log_info "The following services will use these admin credentials:"
    [[ "$COMPOSE_PROFILES_VALUE" == *"langfuse"* ]] && echo "  - Langfuse (LLM Observability) - Port 8096"
    [[ "$COMPOSE_PROFILES_VALUE" == *"monitoring"* ]] && echo "  - Grafana (Monitoring Dashboard) - Port 8003"
    echo ""
    log_info "Configure unified admin account for these services"
    echo ""
    
    # Email with validation and confirmation
    while true; do
        read -p "Admin Email: " ADMIN_EMAIL
        
        # Validate format
        if [[ ! "$ADMIN_EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
            log_error "Invalid email format. Please try again."
            continue
        fi
        
        # Confirm email
        echo ""
        log_info "Email: $ADMIN_EMAIL"
        read -p "Is this correct? (Y/n): " confirm_email
        if [[ ! "$confirm_email" =~ ^[Nn]$ ]]; then
            break
        else
            echo ""
            log_info "Let's try again..."
        fi
    done
    
    # Password with confirmation
    while true; do
        read -sp "Admin Password: " ADMIN_PASSWORD
        echo ""
        read -sp "Confirm Password: " ADMIN_PASSWORD_CONFIRM
        echo ""
        
        if [ "$ADMIN_PASSWORD" = "$ADMIN_PASSWORD_CONFIRM" ]; then
            if [ ${#ADMIN_PASSWORD} -lt 8 ]; then
                log_error "Password must be at least 8 characters. Try again."
            else
                log_success "✅ Passwords match"
                break
            fi
        else
            log_error "❌ Passwords don't match. Try again."
        fi
    done
    
    # Write to .env
    sed -i.bak "/^ADMIN_EMAIL=/d" "$ENV_FILE"
    sed -i.bak "/^ADMIN_PASSWORD=/d" "$ENV_FILE"
    echo "ADMIN_EMAIL=$ADMIN_EMAIL" >> "$ENV_FILE"
    echo "ADMIN_PASSWORD=$ADMIN_PASSWORD" >> "$ENV_FILE"
    
    log_success "Admin credentials configured for selected services"
fi

echo ""
log_info "🌐 Network Configuration for LAN Access"
log_info "======================================"

# Auto-detect LAN IP address
LAN_IP=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $7; exit}' || ip addr show | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}' | cut -d'/' -f1 || echo "")

if [[ -n "$LAN_IP" && "$LAN_IP" != "127.0.0.1" ]]; then
    echo ""
    log_success "✅ Detected LAN IP address: $LAN_IP"
    echo ""
    log_info "This IP will be used for network access from all devices"
    log_info "Services will be accessible at: http://$LAN_IP:PORT"
    echo ""
    read -p "Use this IP address for network access? (Y/n): " use_lan_ip
    
    if [[ ! "$use_lan_ip" =~ ^[Nn]$ ]]; then
        DETECTED_SERVER_IP="$LAN_IP"
        log_success "✅ Configured for LAN access: $DETECTED_SERVER_IP"
    else
        echo ""
        read -p "Enter custom IP address (or press Enter for localhost only): " custom_ip
        DETECTED_SERVER_IP="${custom_ip:-127.0.0.1}"
        if [ "$DETECTED_SERVER_IP" = "127.0.0.1" ]; then
            log_warning "⚠️ Using localhost - services only accessible from server"
        else
            log_info "Using custom IP: $DETECTED_SERVER_IP"
        fi
    fi
else
    log_warning "⚠️ Could not auto-detect LAN IP"
    echo ""
    read -p "Enter your server's LAN IP address (or press Enter for localhost): " manual_ip
    DETECTED_SERVER_IP="${manual_ip:-127.0.0.1}"
    if [ "$DETECTED_SERVER_IP" = "127.0.0.1" ]; then
        log_warning "⚠️ Using localhost - services only accessible from server"
    else
        log_info "Using IP: $DETECTED_SERVER_IP"
    fi
fi

# Update SERVER_IP in .env
if [ -f "$ENV_FILE" ]; then
    sed -i.bak "/^SERVER_IP=/d" "$ENV_FILE"
    echo "SERVER_IP=$DETECTED_SERVER_IP" >> "$ENV_FILE"
    log_success "✅ SERVER_IP configured: $DETECTED_SERVER_IP"
fi

echo ""
log_info "🌐 Network Configuration Summary"
log_info "======================================"
log_info "Server IP: $DETECTED_SERVER_IP"
log_info "Selected services: ${COMPOSE_PROFILES_VALUE:-none (core only)}"
log_info "Access method: HTTP via IP and port"
log_info "Port range: 8000-8099"
log_info "Mail system: Mailpit (local capture only)"
log_info "Authentication: Disabled for local network"

echo ""
log_info "Services will be accessible at:"
log_info "- n8n: http://$DETECTED_SERVER_IP:8000"
log_info "- Flowise: http://$DETECTED_SERVER_IP:8022"
log_info "- Grafana: http://$DETECTED_SERVER_IP:8003"
log_info "- All services: http://$DETECTED_SERVER_IP:8000-8099"

echo ""
read -p "Continue with installation? (Y/n): " confirm_installation
if [[ "$confirm_installation" =~ ^[Nn]$ ]]; then
    log_info "Installation cancelled by user."
    exit 0
fi

log_success "Local network service selection completed!"

exit 0
