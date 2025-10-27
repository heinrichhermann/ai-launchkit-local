#!/bin/bash

# AI LaunchKit Service Health Check with Detailed Logging
# Tests all services displayed on the landing page

cd "$(dirname "$0")/.."

# Get SERVER_IP from .env
SERVER_IP=$(grep "^SERVER_IP=" .env 2>/dev/null | cut -d'=' -f2 | tr -d '"' || echo "127.0.0.1")

# Create log file
LOG_FILE="diagnose_services_detailed_$(date +%Y%m%d_%H%M%S).log"

# Initialize log
{
    echo "🔍 AI LaunchKit Detailed Service Diagnostics"
    echo "Generated: $(date)"
    echo "Server: $SERVER_IP"
    echo "=========================================="
    echo ""
} > "$LOG_FILE"

# Logging function
log_detail() {
    echo "$1" >> "$LOG_FILE"
}

# Enhanced test function with detailed logging
test_service() {
    local name="$1"
    local url="$2"
    local timeout="${3:-5}"
    
    log_detail "## Testing: $name"
    log_detail "URL: $url"
    log_detail "Timeout: ${timeout}s"
    
    # Measure response time and get status
    local start_time=$(date +%s%N)
    local response=$(curl -sf --max-time "$timeout" --connect-timeout 3 -w "\n%{http_code}\n%{time_total}" "$url" 2>&1)
    local curl_exit=$?
    local end_time=$(date +%s%N)
    
    # Calculate response time in ms
    local response_time=$(( (end_time - start_time) / 1000000 ))
    
    # Parse response
    local http_code=$(echo "$response" | tail -n 2 | head -n 1)
    local time_total=$(echo "$response" | tail -n 1)
    
    log_detail "Exit Code: $curl_exit"
    log_detail "HTTP Code: $http_code"
    log_detail "Response Time: ${response_time}ms"
    
    # Accept 2xx and 3xx codes as SUCCESS (redirects are normal for web apps)
    if [ $curl_exit -eq 0 ] && [[ "$http_code" =~ ^[23] ]] || [ -z "$http_code" ]; then
        echo "✅ $name: ONLINE ($url) [HTTP $http_code]"
        log_detail "Status: ✅ ONLINE"
        log_detail ""
        return 0
    else
        echo "❌ $name: ERROR/TIMEOUT ($url)"
        log_detail "Status: ❌ FAILED"
        
        # Get detailed error info
        log_detail "Error Details:"
        local error_output=$(curl -v --max-time "$timeout" "$url" 2>&1 | tail -20)
        log_detail "$error_output"
        
        # Check container status
        local container_name=$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/ .*//g')
        if docker ps -a --format "{{.Names}}" | grep -qi "$container_name"; then
            local actual_container=$(docker ps -a --format "{{.Names}}" | grep -i "$container_name" | head -1)
            log_detail ""
            log_detail "Container Status:"
            docker ps -a --filter "name=$actual_container" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" >> "$LOG_FILE" 2>&1
            
            log_detail ""
            log_detail "Recent Container Logs (last 20 lines):"
            docker logs "$actual_container" --tail 20 >> "$LOG_FILE" 2>&1
        fi
        
        log_detail ""
        return 1
    fi
}

SUCCESS=0
FAILED=0

echo "🔍 AI LaunchKit Service Health Check"
echo "Server: $SERVER_IP"
echo "Log File: $LOG_FILE"
echo "=========================================="
echo ""

log_detail "=========================================="
log_detail "SERVICE HEALTH CHECKS"
log_detail "=========================================="
log_detail ""

echo "## AI CORE SERVICES"
echo "-----------------------------------"
log_detail "## AI CORE SERVICES"
test_service "n8n Workflows" "http://$SERVER_IP:8000" && ((SUCCESS++)) || ((FAILED++))
test_service "Flowise AI Agents" "http://$SERVER_IP:8022" && ((SUCCESS++)) || ((FAILED++))
test_service "Open WebUI" "http://$SERVER_IP:8020" && ((SUCCESS++)) || ((FAILED++))
test_service "bolt.diy" "http://$SERVER_IP:8023" && ((SUCCESS++)) || ((FAILED++))
test_service "ComfyUI" "http://$SERVER_IP:8024" && ((SUCCESS++)) || ((FAILED++))
test_service "OpenUI" "http://$SERVER_IP:8025" && ((SUCCESS++)) || ((FAILED++))

echo ""
echo "## RAG & VECTOR APPS"
echo "-----------------------------------"
log_detail ""
log_detail "## RAG & VECTOR APPS"
test_service "Neo4j" "http://$SERVER_IP:8028" && ((SUCCESS++)) || ((FAILED++))
test_service "LightRAG" "http://$SERVER_IP:8029" && ((SUCCESS++)) || ((FAILED++))
test_service "RAGApp" "http://$SERVER_IP:8030" && ((SUCCESS++)) || ((FAILED++))

echo ""
echo "## LEARNING TOOLS"
echo "-----------------------------------"
log_detail ""
log_detail "## LEARNING TOOLS"
test_service "Cal.com" "http://$SERVER_IP:8040" && ((SUCCESS++)) || ((FAILED++))
test_service "Baserow" "http://$SERVER_IP:8047" && ((SUCCESS++)) || ((FAILED++))
test_service "NocoDB" "http://$SERVER_IP:8048" && ((SUCCESS++)) || ((FAILED++))
test_service "Vikunja" "http://$SERVER_IP:8049" && ((SUCCESS++)) || ((FAILED++))
test_service "Leantime" "http://$SERVER_IP:8050" && ((SUCCESS++)) || ((FAILED++))

echo ""
echo "## VOICE & DOCUMENTS"
echo "-----------------------------------"
log_detail ""
log_detail "## VOICE & DOCUMENTS"
test_service "Scriberr" "http://$SERVER_IP:8083" && ((SUCCESS++)) || ((FAILED++))
test_service "Stirling-PDF" "http://$SERVER_IP:8086" && ((SUCCESS++)) || ((FAILED++))

echo ""
echo "## SEARCH & DISCOVERY"
echo "-----------------------------------"
log_detail ""
log_detail "## SEARCH & DISCOVERY"
test_service "SearXNG" "http://$SERVER_IP:8089" && ((SUCCESS++)) || ((FAILED++))
test_service "Perplexica" "http://$SERVER_IP:8090" && ((SUCCESS++)) || ((FAILED++))
test_service "Crawl4AI" "http://$SERVER_IP:8093" && ((SUCCESS++)) || ((FAILED++))

echo ""
echo "## MONITORING"
echo "-----------------------------------"
log_detail ""
log_detail "## MONITORING"
test_service "Grafana" "http://$SERVER_IP:8003" && ((SUCCESS++)) || ((FAILED++))
test_service "Prometheus" "http://$SERVER_IP:8004/metrics" && ((SUCCESS++)) || ((FAILED++))
test_service "Portainer" "http://$SERVER_IP:8007" && ((SUCCESS++)) || ((FAILED++))
test_service "Langfuse" "http://$SERVER_IP:8096" && ((SUCCESS++)) || ((FAILED++))

echo ""
echo "## UTILITIES"
echo "-----------------------------------"
log_detail ""
log_detail "## UTILITIES"
test_service "Mailpit" "http://$SERVER_IP:8071" && ((SUCCESS++)) || ((FAILED++))
test_service "Postiz" "http://$SERVER_IP:8060" && ((SUCCESS++)) || ((FAILED++))
test_service "Vaultwarden" "http://$SERVER_IP:8061" && ((SUCCESS++)) || ((FAILED++))
test_service "LibreTranslate" "http://$SERVER_IP:8082" && ((SUCCESS++)) || ((FAILED++))

echo ""
echo "## DEVELOPER APIs"
echo "-----------------------------------"
log_detail ""
log_detail "## DEVELOPER APIs"
test_service "Ollama API" "http://$SERVER_IP:8021/api/tags" && ((SUCCESS++)) || ((FAILED++))
test_service "Weaviate API" "http://$SERVER_IP:8027/v1/.well-known/ready" && ((SUCCESS++)) || ((FAILED++))
test_service "Qdrant API" "http://$SERVER_IP:8026" && ((SUCCESS++)) || ((FAILED++))
test_service "Whisper API" "http://$SERVER_IP:8080/docs" && ((SUCCESS++)) || ((FAILED++))
test_service "OpenedAI TTS" "http://$SERVER_IP:8081" && ((SUCCESS++)) || ((FAILED++))
test_service "Chatterbox TTS" "http://$SERVER_IP:8087/health" && ((SUCCESS++)) || ((FAILED++))
test_service "Gotenberg" "http://$SERVER_IP:8094/health" && ((SUCCESS++)) || ((FAILED++))
test_service "Tesseract OCR" "http://$SERVER_IP:8084/status" && ((SUCCESS++)) || ((FAILED++))
test_service "EasyOCR" "http://$SERVER_IP:8085" && ((SUCCESS++)) || ((FAILED++))
test_service "ClickHouse" "http://$SERVER_IP:8097/ping" && ((SUCCESS++)) || ((FAILED++))
test_service "MinIO API" "http://$SERVER_IP:8098/minio/health/live" && ((SUCCESS++)) || ((FAILED++))
test_service "MinIO Console" "http://$SERVER_IP:8099" && ((SUCCESS++)) || ((FAILED++))

# Summary
echo ""
echo "=========================================="
echo "📊 SUMMARY"
echo "=========================================="
echo "✅ Online: $SUCCESS"
echo "❌ Failed/Timeout: $FAILED"
TOTAL=$((SUCCESS + FAILED))
PERCENT=$((SUCCESS * 100 / TOTAL))
echo "📈 Success Rate: $PERCENT%"
echo ""
echo "📋 Detailed log saved to: $LOG_FILE"
echo ""

# Write summary to log
{
    echo ""
    echo "=========================================="
    echo "FINAL SUMMARY"
    echo "=========================================="
    echo "✅ Online: $SUCCESS"
    echo "❌ Failed/Timeout: $FAILED"
    echo "Total Tested: $TOTAL"
    echo "Success Rate: $PERCENT%"
    echo ""
    echo "Timestamp: $(date)"
} >> "$LOG_FILE"

if [ $FAILED -eq 0 ]; then
    echo "🎉 ALL SERVICES OPERATIONAL!"
    exit 0
else
    echo "⚠️  Some services need attention"
    echo ""
    echo "💡 Next steps:"
    echo "   1. Review detailed log: cat $LOG_FILE"
    echo "   2. Check failed services: docker ps -a | grep -E 'Exited|Restarting'"
    echo "   3. View specific logs: docker logs SERVICE_NAME"
    echo ""
    echo "📤 To share with support: Upload or paste $LOG_FILE"
    exit 1
fi
