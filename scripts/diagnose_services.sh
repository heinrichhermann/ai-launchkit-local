#!/bin/bash

# AI LaunchKit Service Diagnostics Script
# Collects logs and status information for troubleshooting

set -e

cd "$(dirname "$0")/.."

OUTPUT_FILE="diagnostic_report_$(date +%Y%m%d_%H%M%S).txt"

echo "🔍 AI LaunchKit Service Diagnostics" > "$OUTPUT_FILE"
echo "Generated: $(date)" >> "$OUTPUT_FILE"
echo "========================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 1. System Information
echo "## SYSTEM INFO" >> "$OUTPUT_FILE"
echo "-----------------------------------" >> "$OUTPUT_FILE"
echo "Hostname: $(hostname)" >> "$OUTPUT_FILE"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)" >> "$OUTPUT_FILE"
echo "Docker Version: $(docker --version)" >> "$OUTPUT_FILE"
echo "Docker Compose: $(docker compose version)" >> "$OUTPUT_FILE"
echo "Memory: $(free -h | grep Mem | awk '{print $2" total, "$3" used, "$7" available"}')" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 2. Container Status
echo "## CONTAINER STATUS" >> "$OUTPUT_FILE"
echo "-----------------------------------" >> "$OUTPUT_FILE"
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" >> "$OUTPUT_FILE" 2>&1
echo "" >> "$OUTPUT_FILE"

# 3. Failed/Restarting Containers
echo "## PROBLEMATIC CONTAINERS" >> "$OUTPUT_FILE"
echo "-----------------------------------" >> "$OUTPUT_FILE"
FAILED_CONTAINERS=$(docker ps -a --filter "status=exited" --filter "status=restarting" --format "{{.Names}}")
if [ -z "$FAILED_CONTAINERS" ]; then
    echo "No failed containers found" >> "$OUTPUT_FILE"
else
    echo "$FAILED_CONTAINERS" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# 4. Environment Variables (ANONYMIZED - no secrets)
echo "## .ENV CONFIGURATION (Secrets Hidden)" >> "$OUTPUT_FILE"
echo "-----------------------------------" >> "$OUTPUT_FILE"
echo "SERVER_IP: $(grep "^SERVER_IP=" .env | cut -d'=' -f2)" >> "$OUTPUT_FILE"
echo "COMPOSE_PROFILES: $(grep "^COMPOSE_PROFILES=" .env | cut -d'=' -f2)" >> "$OUTPUT_FILE"
echo "N8N_WORKER_COUNT: $(grep "^N8N_WORKER_COUNT=" .env | cut -d'=' -f2)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Check for quotes in critical variables
echo "## CRITICAL: Checking for quotes in .env" >> "$OUTPUT_FILE"
echo "-----------------------------------" >> "$OUTPUT_FILE"
HAS_QUOTES=$(grep -E '^(POSTGRES_PASSWORD|N8N_ENCRYPTION_KEY|CALCOM_|WEAVIATE_API_KEY)="' .env 2>/dev/null | wc -l)
if [ "$HAS_QUOTES" -gt 0 ]; then
    echo "⚠️ WARNING: Found $HAS_QUOTES variables with quotes!" >> "$OUTPUT_FILE"
    echo "Run: bash scripts/repair_env_quotes.sh" >> "$OUTPUT_FILE"
else
    echo "✅ No quote issues found" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# 5. Individual Service Logs
echo "## SERVICE LOGS (Last 30 lines each)" >> "$OUTPUT_FILE"
echo "========================================" >> "$OUTPUT_FILE"

# Check each important service
for SERVICE in "postgres" "redis" "n8n" "calcom" "flowise" "weaviate" "ollama"; do
    if docker ps -a --format "{{.Names}}" | grep -q "^${SERVICE}$"; then
        echo "" >> "$OUTPUT_FILE"
        echo "### $SERVICE" >> "$OUTPUT_FILE"
        echo "-----------------------------------" >> "$OUTPUT_FILE"
        echo "Status: $(docker inspect --format='{{.State.Status}}' $SERVICE 2>/dev/null || echo 'Not found')" >> "$OUTPUT_FILE"
        echo "Health: $(docker inspect --format='{{.State.Health.Status}}' $SERVICE 2>/dev/null || echo 'No healthcheck')" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        echo "Last 30 log lines:" >> "$OUTPUT_FILE"
        docker logs $SERVICE --tail 30 >> "$OUTPUT_FILE" 2>&1 || echo "Failed to get logs" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
done

# 6. Database Status
echo "## DATABASE DIAGNOSTICS" >> "$OUTPUT_FILE"
echo "-----------------------------------" >> "$OUTPUT_FILE"
echo "Postgres databases:" >> "$OUTPUT_FILE"
docker exec postgres psql -U postgres -c "\l" 2>&1 | grep -E "(Name|calcom|nocodb|baserow|langfuse|formbricks|metabase|vikunja)" >> "$OUTPUT_FILE" || echo "Failed to list databases" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 7. Network Connectivity
echo "## NETWORK CONNECTIVITY" >> "$OUTPUT_FILE"
echo "-----------------------------------" >> "$OUTPUT_FILE"
echo "Docker networks:" >> "$OUTPUT_FILE"
docker network ls | grep localai >> "$OUTPUT_FILE" || echo "No localai network found" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 8. Disk Space
echo "## DISK USAGE" >> "$OUTPUT_FILE"
echo "-----------------------------------" >> "$OUTPUT_FILE"
df -h | grep -E "(Filesystem|/$|docker)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Docker volumes size:" >> "$OUTPUT_FILE"
docker system df -v | head -20 >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 9. Recent Docker Events
echo "## RECENT DOCKER EVENTS (Last 50)" >> "$OUTPUT_FILE"
echo "-----------------------------------" >> "$OUTPUT_FILE"
docker events --since 10m --until 0s >> "$OUTPUT_FILE" 2>&1 &
sleep 2
pkill -P $$ docker 2>/dev/null || true
echo "" >> "$OUTPUT_FILE"

echo "========================================" >> "$OUTPUT_FILE"
echo "Diagnostic report complete" >> "$OUTPUT_FILE"
echo "========================================" >> "$OUTPUT_FILE"

echo ""
echo "✅ Diagnostic report saved to: $OUTPUT_FILE"
echo ""
echo "📋 To share this with support:"
echo "   cat $OUTPUT_FILE"
echo ""
echo "🔧 Common fixes:"
echo "   - Quotes in .env: bash scripts/repair_env_quotes.sh"
echo "   - Restart all: docker compose -p localai -f docker-compose.local.yml restart"
echo "   - Fresh start: docker compose -p localai -f docker-compose.local.yml down && docker compose -p localai -f docker-compose.local.yml up -d"
echo ""

exit 0
