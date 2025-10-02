#!/bin/bash

set -e

# Source the utilities file
source "$(dirname "$0")/utils.sh"

# Check for openssl
if ! command -v openssl &> /dev/null; then
    log_error "openssl could not be found. Please ensure it is installed and available in your PATH." >&2
    exit 1
fi

# Check for Python3 (needed for password hashing)
if ! command -v python3 &> /dev/null; then
    log_error "python3 could not be found. Installing python3-bcrypt..." >&2
    apt-get update && apt-get install -y python3 python3-pip python3-bcrypt || {
        log_error "Failed to install Python3 and bcrypt. Please install manually." >&2
        exit 1
    }
fi

# --- Configuration ---
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." &> /dev/null && pwd )"
TEMPLATE_FILE="$PROJECT_ROOT/.env.local.example"
OUTPUT_FILE="$PROJECT_ROOT/.env"
ENV_FILE="$OUTPUT_FILE"

# Variables to generate: varName="type:length"
# Types: password (alphanum), secret (base64), hex, base64, alphanum
declare -A VARS_TO_GENERATE=(
    ["FLOWISE_PASSWORD"]="password:32"
    ["BOLT_PASSWORD"]="password:32"
    ["N8N_ENCRYPTION_KEY"]="secret:64"
    ["N8N_USER_MANAGEMENT_JWT_SECRET"]="secret:64"
    ["POSTGRES_PASSWORD"]="password:32"
    ["POSTGRES_NON_ROOT_PASSWORD"]="password:32"
    ["JWT_SECRET"]="base64:64"
    ["DASHBOARD_PASSWORD"]="password:32"
    ["CLICKHOUSE_PASSWORD"]="password:32"
    ["MINIO_ROOT_PASSWORD"]="password:32"
    ["LANGFUSE_SALT"]="secret:64"
    ["NEXTAUTH_SECRET"]="secret:64"
    ["ENCRYPTION_KEY"]="hex:64"
    ["GRAFANA_ADMIN_PASSWORD"]="password:32"
    ["SECRET_KEY_BASE"]="base64:64"
    ["VAULT_ENC_KEY"]="alphanum:32"
    ["LOGFLARE_PRIVATE_ACCESS_TOKEN"]="fixed:not-in-use"
    ["LOGFLARE_PUBLIC_ACCESS_TOKEN"]="fixed:not-in-use"
    ["PROMETHEUS_PASSWORD"]="password:32"
    ["SEARXNG_PASSWORD"]="password:32"
    ["LETTA_SERVER_PASSWORD"]="password:32"
    ["LANGFUSE_INIT_USER_PASSWORD"]="password:32"
    ["LANGFUSE_INIT_PROJECT_PUBLIC_KEY"]="langfuse_pk:32"
    ["LANGFUSE_INIT_PROJECT_SECRET_KEY"]="langfuse_sk:32"
    ["WEAVIATE_API_KEY"]="secret:48"
    ["QDRANT_API_KEY"]="secret:48"
    ["NEO4J_AUTH_PASSWORD"]="password:32"
    ["NEO4J_AUTH_USERNAME"]="fixed:neo4j"
    ["DIFY_SECRET_KEY"]="secret:64"
    ["COMFYUI_PASSWORD"]="password:32"
    ["RAGAPP_PASSWORD"]="password:32"
    ["LIBRETRANSLATE_PASSWORD"]="password:32"
    ["WHISPER_AUTH_PASSWORD"]="password:32"
    ["TTS_AUTH_PASSWORD"]="password:32"
    ["EASYOCR_SECRET_KEY"]="apikey:32"
    ["LIGHTRAG_PASSWORD"]="password:32"
    ["LIGHTRAG_TOKEN_SECRET"]="apikey:64"
    ["LIGHTRAG_AUTH_ACCOUNTS"]="special:lightrag_auth"
    ["PERPLEXICA_PASSWORD"]="password:32"
    ["BASEROW_SECRET_KEY"]="secret:64"
    ["NOCODB_ADMIN_PASSWORD"]="password:32"
    ["NOCODB_JWT_SECRET"]="apikey:40"
    ["VIKUNJA_JWT_SECRET"]="apikey:32"
    ["MYSQL_ROOT_PASSWORD"]="password:32"
    ["LEANTIME_DB_PASSWORD"]="password:32"
    ["LEANTIME_SESSION_PASSWORD"]="password:64"
    ["CALCOM_NEXTAUTH_SECRET"]="apikey:32"
    ["CALCOM_ENCRYPTION_KEY"]="apikey:32"
    ["VAULTWARDEN_ADMIN_TOKEN"]="apikey:64"
    ["KOPIA_UI_PASSWORD"]="password:32"
    ["KOPIA_PASSWORD"]="password:32"
    ["FORMBRICKS_NEXTAUTH_SECRET"]="apikey:32"
    ["FORMBRICKS_ENCRYPTION_KEY"]="apikey:32"
    ["FORMBRICKS_CRON_SECRET"]="apikey:32"
    ["FORMBRICKS_DB_PASSWORD"]="password:32"
    ["METABASE_ENCRYPTION_KEY"]="apikey:32"
    ["METABASE_DB_PASSWORD"]="password:32"
    ["CHATTERBOX_API_KEY"]="apikey:32"
    ["MAILPIT_PASSWORD"]="password:32"
    ["SMTP_PASS"]="password:16"
    ["MAIL_NOREPLY_PASSWORD"]="password:32"
)

# Initialize existing_env_vars and attempt to read .env if it exists
log_info "Initializing local network environment configuration..."
declare -A existing_env_vars
declare -A generated_values

if [ -f "$OUTPUT_FILE" ]; then
    log_info "Found existing $OUTPUT_FILE. Reading its values to use as defaults and preserve current settings."
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ -n "$line" && ! "$line" =~ ^\s*# && "$line" == *"="* ]]; then
            varName=$(echo "$line" | cut -d'=' -f1 | xargs)
            varValue=$(echo "$line" | cut -d'=' -f2-)
            # Repeatedly unquote "value" or 'value' to get the bare value
            _tempVal="$varValue"
            while true; do
                if [[ "$_tempVal" =~ ^\"(.*)\"$ ]]; then # Check double quotes
                    _tempVal="${BASH_REMATCH[1]}"
                    continue
                fi
                if [[ "$_tempVal" =~ ^\'(.*)\'$ ]]; then # Check single quotes
                    _tempVal="${BASH_REMATCH[1]}"
                    continue
                fi
                break # No more surrounding quotes of these types
            done
            varValue="$_tempVal"
            existing_env_vars["$varName"]="$varValue"
        fi
    done < "$OUTPUT_FILE"
fi

# NO CADDY INSTALLATION - Use Python for password hashing instead

# Check if Python bcrypt is available
python3 -c "import bcrypt" 2>/dev/null || {
    log_info "Installing Python bcrypt library for password hashing..."
    pip3 install bcrypt || {
        log_error "Failed to install bcrypt. Trying alternative installation..."
        apt-get install -y python3-bcrypt || {
            log_error "Could not install bcrypt. Password hashing will be skipped."
        }
    }
}

# Set local network configuration (no domain prompts)
SERVER_IP="127.0.0.1"  # Default for local testing
USER_EMAIL="admin@localhost"  # Default email for local setup

log_info "Configuring for local network deployment..."
log_info "Server IP: $SERVER_IP"
log_info "Admin Email: $USER_EMAIL"

# Configure API keys (can be left empty for local use)
OPENAI_API_KEY="${existing_env_vars[OPENAI_API_KEY]:-}"
ANTHROPIC_API_KEY="${existing_env_vars[ANTHROPIC_API_KEY]:-}"
GROQ_API_KEY="${existing_env_vars[GROQ_API_KEY]:-}"

# n8n workflows import decision
final_run_n8n_import_decision="false"
echo ""
echo "Do you want to import 300 ready-made workflows for n8n? This process may take about 30 minutes to complete."
echo ""
read -p "Import workflows? (y/n): " import_workflow_choice

if [[ "$import_workflow_choice" =~ ^[Yy]$ ]]; then
    final_run_n8n_import_decision="true"
else
    final_run_n8n_import_decision="false"
fi

# Number of n8n workers
echo ""
log_info "Configuring n8n worker count..."
if [[ -n "${existing_env_vars[N8N_WORKER_COUNT]}" ]]; then
    N8N_WORKER_COUNT_CURRENT="${existing_env_vars[N8N_WORKER_COUNT]}"
    echo ""
    read -p "Current n8n workers: $N8N_WORKER_COUNT_CURRENT. Change? (Enter new number or press Enter to keep): " N8N_WORKER_COUNT_INPUT_RAW
    if [[ -z "$N8N_WORKER_COUNT_INPUT_RAW" ]]; then
        N8N_WORKER_COUNT="$N8N_WORKER_COUNT_CURRENT"
    else
        if [[ "$N8N_WORKER_COUNT_INPUT_RAW" =~ ^[1-9][0-9]*$ ]]; then
            N8N_WORKER_COUNT="$N8N_WORKER_COUNT_INPUT_RAW"
        else
            log_warning "Invalid input. Keeping current value: $N8N_WORKER_COUNT_CURRENT"
            N8N_WORKER_COUNT="$N8N_WORKER_COUNT_CURRENT"
        fi
    fi
else
    while true; do
        echo ""
        read -p "Enter the number of n8n workers to run (default is 1): " N8N_WORKER_COUNT_INPUT_RAW
        N8N_WORKER_COUNT_CANDIDATE="${N8N_WORKER_COUNT_INPUT_RAW:-1}"

        if [[ "$N8N_WORKER_COUNT_CANDIDATE" =~ ^[1-9][0-9]*$ ]]; then
            N8N_WORKER_COUNT="$N8N_WORKER_COUNT_CANDIDATE"
            break
        else
            log_error "Please enter a positive integer (e.g., 1, 2, 3)." >&2
        fi
    done
fi

log_info "Generating secrets and creating .env file..."

# --- Helper Functions ---
gen_random() {
    local length="$1"
    local characters="$2"
    head /dev/urandom | tr -dc "$characters" | head -c "$length"
}

gen_password() {
    gen_random "$1" 'A-Za-z0-9'
}

gen_hex() {
    local length="$1"
    local bytes=$(( (length + 1) / 2 ))
    openssl rand -hex "$bytes" | head -c "$length"
}

gen_base64() {
    local length="$1"
    local bytes=$(( (length * 3 + 3) / 4 ))
    openssl rand -base64 "$bytes" | head -c "$length"
}

# Function to update or add a variable to the .env file
_update_or_add_env_var() {
    local var_name="$1"
    local var_value="$2"
    local tmp_env_file

    tmp_env_file=$(mktemp)

    if [[ -f "$OUTPUT_FILE" ]]; then
        grep -v -E "^${var_name}=" "$OUTPUT_FILE" > "$tmp_env_file" || true
    else
        touch "$tmp_env_file"
    fi

    if [[ -n "$var_value" ]]; then
        echo "${var_name}='$var_value'" >> "$tmp_env_file"
    fi
    mv "$tmp_env_file" "$OUTPUT_FILE"
}

# Function to generate password hash using Python bcrypt
_generate_password_hash() {
    local plain_password="$1"
    local new_hash=""
    if [[ -n "$plain_password" ]]; then
        new_hash=$(python3 -c "
import bcrypt
import sys
password = sys.argv[1]
hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
print(hash)
" "$plain_password" 2>/dev/null)
        if [[ $? -ne 0 || -z "$new_hash" ]]; then
            log_warning "Failed to generate password hash for local authentication"
            new_hash=""
        fi
    fi
    echo "$new_hash"
}

# ============================================================================
# LOCAL NETWORK MAIL CONFIGURATION
# ============================================================================
configure_local_mail() {
    echo
    echo "📧 Configuring Mail System for Local Network..."
    echo "=============================================="
    
    log_info "Mail system configured for local network access"
    log_info "All emails will be captured by Mailpit (no external delivery)"
    
    # Local mail configuration
    MAIL_MODE="mailpit"
    SMTP_HOST="mailpit"
    SMTP_PORT="1025"
    SMTP_FROM="noreply@localhost"
    SMTP_SECURE="false"
    
    # Store mail configuration
    generated_values["MAIL_MODE"]="$MAIL_MODE"
    generated_values["SMTP_HOST"]="$SMTP_HOST"
    generated_values["SMTP_PORT"]="$SMTP_PORT"
    generated_values["SMTP_FROM"]="$SMTP_FROM"
    generated_values["SMTP_SECURE"]="$SMTP_SECURE"
    generated_values["SMTP_USER"]="admin"
    generated_values["SMTP_PASS"]="admin"
    
    echo "✅ Local mail configuration completed"
    echo
}

# Force EMAIL_* variables to mirror SMTP_* for service compatibility
force_update_email_variables() {
    _update_or_add_env_var "EMAIL_FROM" "${generated_values[SMTP_FROM]:-noreply@localhost}"
    _update_or_add_env_var "EMAIL_SMTP" "${generated_values[SMTP_HOST]:-mailpit}"
    _update_or_add_env_var "EMAIL_SMTP_HOST" "${generated_values[SMTP_HOST]:-mailpit}"
    _update_or_add_env_var "EMAIL_SMTP_PORT" "${generated_values[SMTP_PORT]:-1025}"
    _update_or_add_env_var "EMAIL_SMTP_USER" "${generated_values[SMTP_USER]:-admin}"
    _update_or_add_env_var "EMAIL_SMTP_PASSWORD" "${generated_values[SMTP_PASS]:-admin}"
    _update_or_add_env_var "EMAIL_SMTP_USE_TLS" "${generated_values[SMTP_SECURE]:-false}"
}

# --- Main Logic ---

if [ ! -f "$TEMPLATE_FILE" ]; then
    log_error "Template file not found at $TEMPLATE_FILE" >&2
    log_error "Please ensure .env.local.example exists" >&2
    exit 1
fi

# Pre-populate generated_values with non-empty values from existing_env_vars
for key_from_existing in "${!existing_env_vars[@]}"; do
    if [[ -n "${existing_env_vars[$key_from_existing]}" ]]; then
        generated_values["$key_from_existing"]="${existing_env_vars[$key_from_existing]}"
    fi
done

# Generate missing variables from VARS_TO_GENERATE
for varName in "${!VARS_TO_GENERATE[@]}"; do
    # Skip if already has a value
    if [[ -n "${generated_values[$varName]}" ]]; then
        continue
    fi

    IFS=':' read -r type length <<< "${VARS_TO_GENERATE[$varName]}"
    newValue=""
    case "$type" in
        password|alphanum) newValue=$(gen_password "$length") ;;
        secret|base64) newValue=$(gen_base64 "$length") ;;
        hex) newValue=$(gen_hex "$length") ;;
        apikey) newValue=$(gen_hex "$length") ;;
        langfuse_pk) newValue="pk-lf-$(gen_hex "$length")" ;;
        langfuse_sk) newValue="sk-lf-$(gen_hex "$length")" ;;
        fixed) newValue="$length" ;;
        special)
            if [[ "$varName" == "LIGHTRAG_AUTH_ACCOUNTS" && "$length" == "lightrag_auth" ]]; then
                ADMIN_PASS=$(gen_password 16)
                newValue="admin:${ADMIN_PASS}"
            fi
            ;;
        *) log_warning "Unknown generation type '$type' for $varName" ;;
    esac

    if [[ -n "$newValue" ]]; then
        generated_values["$varName"]="$newValue"
    fi
done

# Configure local mail system
configure_local_mail

# Set EMAIL_* variables for service compatibility
generated_values["EMAIL_FROM"]="${generated_values[SMTP_FROM]}"
generated_values["EMAIL_SMTP"]="${generated_values[SMTP_HOST]}"
generated_values["EMAIL_SMTP_HOST"]="${generated_values[SMTP_HOST]}"
generated_values["EMAIL_SMTP_PORT"]="${generated_values[SMTP_PORT]}"
generated_values["EMAIL_SMTP_USER"]="${generated_values[SMTP_USER]}"
generated_values["EMAIL_SMTP_PASSWORD"]="${generated_values[SMTP_PASS]}"
generated_values["EMAIL_SMTP_USE_TLS"]="${generated_values[SMTP_SECURE]}"

# Store local configuration values
generated_values["SERVER_IP"]="$SERVER_IP"
generated_values["FLOWISE_USERNAME"]="$USER_EMAIL"
generated_values["DASHBOARD_USERNAME"]="$USER_EMAIL"
generated_values["LETSENCRYPT_EMAIL"]="$USER_EMAIL"
generated_values["RUN_N8N_IMPORT"]="$final_run_n8n_import_decision"
generated_values["PROMETHEUS_USERNAME"]="$USER_EMAIL"
generated_values["SEARXNG_USERNAME"]="$USER_EMAIL"
generated_values["LANGFUSE_INIT_USER_EMAIL"]="$USER_EMAIL"
generated_values["N8N_WORKER_COUNT"]="$N8N_WORKER_COUNT"
generated_values["WEAVIATE_USERNAME"]="$USER_EMAIL"
generated_values["COMFYUI_USERNAME"]="$USER_EMAIL"
generated_values["RAGAPP_USERNAME"]="$USER_EMAIL"
generated_values["LIBRETRANSLATE_USERNAME"]="$USER_EMAIL"
generated_values["WHISPER_AUTH_USER"]="$USER_EMAIL"
generated_values["TTS_AUTH_USER"]="$USER_EMAIL"
generated_values["LIGHTRAG_USERNAME"]="$USER_EMAIL"
generated_values["PERPLEXICA_USERNAME"]="$USER_EMAIL"
generated_values["BASEROW_USERNAME"]="$USER_EMAIL"
generated_values["KOPIA_UI_USERNAME"]="admin"
generated_values["MAILPIT_USERNAME"]="$USER_EMAIL"

# Set API keys if provided
if [[ -n "$OPENAI_API_KEY" ]]; then
    generated_values["OPENAI_API_KEY"]="$OPENAI_API_KEY"
fi

if [[ -n "$ANTHROPIC_API_KEY" ]]; then
    generated_values["ANTHROPIC_API_KEY"]="$ANTHROPIC_API_KEY"
fi

if [[ -n "$GROQ_API_KEY" ]]; then
    generated_values["GROQ_API_KEY"]="$GROQ_API_KEY"
fi

# Create a temporary file for processing
TMP_ENV_FILE=$(mktemp)
trap 'rm -f "$TMP_ENV_FILE"' EXIT

# Track custom variables
declare -A found_vars
for var in "FLOWISE_USERNAME" "DASHBOARD_USERNAME" "LETSENCRYPT_EMAIL" "RUN_N8N_IMPORT" "PROMETHEUS_USERNAME" "SEARXNG_USERNAME" "OPENAI_API_KEY" "LANGFUSE_INIT_USER_EMAIL" "N8N_WORKER_COUNT" "WEAVIATE_USERNAME" "NEO4J_AUTH_USERNAME" "COMFYUI_USERNAME" "RAGAPP_USERNAME" "LIBRETRANSLATE_USERNAME" "WHISPER_AUTH_USER" "TTS_AUTH_USER" "BASEROW_USERNAME" "KOPIA_UI_USERNAME" "MAILPIT_USERNAME" "EMAIL_FROM" "EMAIL_SMTP" "EMAIL_SMTP_HOST" "EMAIL_SMTP_PORT" "EMAIL_SMTP_USER" "EMAIL_SMTP_PASSWORD" "EMAIL_SMTP_USE_TLS" "SERVER_IP"; do
    found_vars["$var"]=0
done

# Read template and process
while IFS= read -r line || [[ -n "$line" ]]; do
    processed_line="$line"

    # Check if it's a variable assignment line
    if [[ -n "$processed_line" && ! "$processed_line" =~ ^\s*# && "$processed_line" == *"="* ]]; then
        varName=$(echo "$processed_line" | cut -d'=' -f1 | xargs)
        currentValue=$(echo "$processed_line" | cut -d'=' -f2-)

        # Use generated value if available
        if [[ -n "${generated_values[$varName]}" ]]; then
            processed_line="${varName}=\"${generated_values[$varName]}\""
        elif [[ -v VARS_TO_GENERATE["$varName"] && -z "${generated_values[$varName]}" ]]; then
            # Generate value if needed
            IFS=':' read -r type length <<< "${VARS_TO_GENERATE[$varName]}"
            newValue=""
            case "$type" in
                password|alphanum) newValue=$(gen_password "$length") ;;
                secret|base64) newValue=$(gen_base64 "$length") ;;
                hex) newValue=$(gen_hex "$length") ;;
                apikey) newValue=$(gen_hex "$length") ;;
                langfuse_pk) newValue="pk-lf-$(gen_hex "$length")" ;;
                langfuse_sk) newValue="sk-lf-$(gen_hex "$length")" ;;
                fixed) newValue="$length" ;;
                special)
                    if [[ "$varName" == "LIGHTRAG_AUTH_ACCOUNTS" && "$length" == "lightrag_auth" ]]; then
                        ADMIN_PASS=$(gen_password 16)
                        newValue="admin:${ADMIN_PASS}"
                    fi
                    ;;
            esac

            if [[ -n "$newValue" ]]; then
                processed_line="${varName}=\"${newValue}\""
                generated_values["$varName"]="$newValue"
            else
                processed_line="${varName}=\"\""
            fi
        else
            # Mark custom variables as found
            for var in "${!found_vars[@]}"; do
                if [[ "$varName" == "$var" ]]; then
                    found_vars["$var"]=1
                    if [[ -v generated_values[$varName] ]]; then
                        processed_line="${varName}=\"${generated_values[$varName]}\""
                    fi
                    break
                fi
            done
        fi
    fi
    echo "$processed_line" >> "$TMP_ENV_FILE"
done < "$TEMPLATE_FILE"

# Generate Supabase JWT tokens
JWT_SECRET_TO_USE="${generated_values["JWT_SECRET"]}"

if [[ -z "$JWT_SECRET_TO_USE" ]]; then
    JWT_SECRET_TO_USE=$(gen_base64 64)
    generated_values["JWT_SECRET"]="$JWT_SECRET_TO_USE"
fi

# Create JWT tokens
create_jwt() {
    local role=$1
    local jwt_secret=$2
    local now=$(date +%s)
    local exp=$((now + 315360000)) # 10 years from now

    local header='{"alg":"HS256","typ":"JWT"}'
    local payload="{\"role\":\"$role\",\"iss\":\"supabase\",\"iat\":$now,\"exp\":$exp}"

    local b64_header=$(echo -n "$header" | base64 -w 0 | tr '/+' '_-' | tr -d '=')
    local b64_payload=$(echo -n "$payload" | base64 -w 0 | tr '/+' '_-' | tr -d '=')

    local signature_input="$b64_header.$b64_payload"
    local signature=$(echo -n "$signature_input" | openssl dgst -sha256 -hmac "$jwt_secret" -binary | base64 -w 0 | tr '/+' '_-' | tr -d '=')

    echo -n "$b64_header.$b64_payload.$signature"
}

if [[ -z "${generated_values[ANON_KEY]}" ]]; then
    generated_values["ANON_KEY"]=$(create_jwt "anon" "$JWT_SECRET_TO_USE")
fi

if [[ -z "${generated_values[SERVICE_ROLE_KEY]}" ]]; then
    generated_values["SERVICE_ROLE_KEY"]=$(create_jwt "service_role" "$JWT_SECRET_TO_USE")
fi

# Add custom variables not found in template
for var in "FLOWISE_USERNAME" "DASHBOARD_USERNAME" "LETSENCRYPT_EMAIL" "RUN_N8N_IMPORT" "OPENAI_API_KEY" "ANTHROPIC_API_KEY" "GROQ_API_KEY" "PROMETHEUS_USERNAME" "SEARXNG_USERNAME" "LANGFUSE_INIT_USER_EMAIL" "N8N_WORKER_COUNT" "WEAVIATE_USERNAME" "NEO4J_AUTH_USERNAME" "COMFYUI_USERNAME" "RAGAPP_USERNAME" "WHISPER_AUTH_USER" "TTS_AUTH_USER" "LIBRETRANSLATE_USERNAME" "LIGHTRAG_USERNAME" "PERPLEXICA_USERNAME" "ODOO_USERNAME" "BASEROW_USERNAME" "KOPIA_UI_USERNAME" "MAILPIT_USERNAME" "MAUTIC_ADMIN_EMAIL" "MAUTIC_DB_USER" "INVOICENINJA_ADMIN_EMAIL" "EMAIL_FROM" "EMAIL_SMTP" "EMAIL_SMTP_HOST" "EMAIL_SMTP_PORT" "EMAIL_SMTP_USER" "EMAIL_SMTP_PASSWORD" "EMAIL_SMTP_USE_TLS" "SERVER_IP"; do
    if [[ ${found_vars["$var"]} -eq 0 && -v generated_values["$var"] ]]; then
        if ! grep -q -E "^${var}=" "$TMP_ENV_FILE"; then
            echo "${var}=\"${generated_values[$var]}\"" >> "$TMP_ENV_FILE"
        fi
    fi
done

# Copy to output
cp "$TMP_ENV_FILE" "$OUTPUT_FILE"

log_info "Applying variable substitutions..."

# Process substitutions
for key in "${!generated_values[@]}"; do
    value="${generated_values[$key]}"
    
    value_file=$(mktemp)
    echo -n "$value" > "$value_file"
    
    new_output=$(mktemp)
    
    while IFS= read -r line; do
        # Replace ${KEY} format
        if [[ "$line" == *"\${$key}"* ]]; then
            placeholder="\${$key}"
            replacement=$(cat "$value_file")
            line="${line//$placeholder/$replacement}"
        fi

        # Replace $KEY format
        if [[ "$line" == *"$"$key* ]]; then
            placeholder="$"$key
            replacement=$(cat "$value_file")
            line="${line//$placeholder/$replacement}"
        fi

        # Handle specific cases
        if [[ "$key" == "ANON_KEY" && "$line" == "ANON_KEY="* ]]; then
            line="ANON_KEY=\"$(cat "$value_file")\""
        fi

        if [[ "$key" == "SERVICE_ROLE_KEY" && "$line" == "SERVICE_ROLE_KEY="* ]]; then
            line="SERVICE_ROLE_KEY=\"$(cat "$value_file")\""
        fi

        echo "$line" >> "$new_output"
    done < "$OUTPUT_FILE"

    # Replace the output file with the new version
    mv "$new_output" "$OUTPUT_FILE"

    # Clean up
    rm -f "$value_file"
done

# NO PASSWORD HASHING NEEDED FOR LOCAL NETWORK
# All services run without authentication in local network setup
log_info "Skipping password hash generation for local network setup"

# Generate Metabase ENCRYPTION_KEY (exactly 32 hex characters)
if [[ -z "${generated_values[METABASE_ENCRYPTION_KEY]}" ]]; then
    log_info "Generating Metabase ENCRYPTION_KEY..."
    ENCRYPTION_KEY=$(openssl rand -hex 16)  # 16 bytes = 32 hex chars
    generated_values["METABASE_ENCRYPTION_KEY"]="$ENCRYPTION_KEY"
    _update_or_add_env_var "METABASE_ENCRYPTION_KEY" "$ENCRYPTION_KEY"
fi

# Ensure SERVER_IP is written to .env
if [[ -n "${generated_values[SERVER_IP]}" ]]; then
    _update_or_add_env_var "SERVER_IP" "${generated_values[SERVER_IP]}"
fi

if [ $? -eq 0 ]; then
    echo ".env file generated successfully for local network deployment ($OUTPUT_FILE)."
    log_success "Local network configuration complete!"
    echo ""
    echo "🌐 Your AI LaunchKit will be accessible at:"
    echo "   - Server IP: $SERVER_IP (change to your server's LAN IP in .env)"
    echo "   - All services will use ports 8000-8099"
    echo "   - No SSL certificates needed"
    echo "   - No domain configuration required"
    echo ""
else
    log_error "Failed to generate .env file." >&2
    rm -f "$OUTPUT_FILE"
    exit 1
fi

# Force update EMAIL_* variables (must be at the end)
force_update_email_variables

log_success "🚀 Local network secrets and configuration generated successfully!"

exit 0
