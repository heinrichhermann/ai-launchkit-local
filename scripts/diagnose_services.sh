#!/bin/bash

# AI LaunchKit Service Health Check
# Tests all services displayed on the landing page

cd "$(dirname "$0")/.."

# Get SERVER_IP from .env
SERVER_IP=$(grep "^SERVER_IP=" .env 2>/dev/null | cut -d'=' -f2 | tr -d '"' || echo "127.0.0.1")

echo "🔍 AI LaunchKit Service Health Check"
echo "Server: $SERVER_IP"
echo "=========================================="
echo ""

# Test function
test_service() {
    local name="$1"
    local url="$2"
    local timeout="${3:-5}"
    
    if curl -sf --max-time "$timeout" --connect-timeout 3 "$url" > /dev/null 2>&1; then
        echo "✅ $name: ONLINE ($url)"
        return 0
    else
        echo "❌ $name: ERROR/TIMEOUT ($url)"
        return 1
    fi
}

SUCCESS=0
FAILED=0

echo "## AI CORE SERVICES"
echo "-----------------------------------"
test_service "n8n Workflows" "http://$SERVER_IP:8000" && ((SUCCESS++)) || ((FAILED++))
test_service "Flowise AI Agents" "http://$SERVER_IP:8022" && ((SUCCESS++)) || ((FAILED++))
test_service "Open WebUI" "http://$SERVER_IP:8020" && ((SUCCESS++)) || ((FAILED++))
test_service "bolt.diy" "http://$SERVER_IP:8023" && ((SUCCESS++)) || ((FAILED++))
test_service "ComfyUI" "http://$SERVER_IP:8024" && ((SUCCESS++)) || ((FAILED++))
test_service "OpenUI" "http://$SERVER_IP:8025" && ((SUCCESS++)) || ((FAILED++))

echo ""
echo "## RAG & VECTOR APPS"
echo "-----------------------------------"
test_service "Neo4j" "http://$SERVER_IP:8028" && ((SUCCESS++)) || ((FAILED++))
test_service "LightRAG" "http://$SERVER_IP:8029" && ((SUCCESS++)) || ((FAILED++))
test_service "RAGApp" "http://$SERVER_IP:8030" && ((SUCCESS++)) || ((FAILED++))
test_service "Letta" "http://$SERVER_IP:8031" && ((SUCCESS++)) || ((FAILED++))

echo ""
echo "## LEARNING TOOLS"
echo "-----------------------------------"
test_service "Cal.com" "http://$SERVER_IP:8040" && ((SUCCESS++)) || ((FAILED++))
test_service "Baserow" "http://$SERVER_IP:8047" && ((SUCCESS++)) || ((FAILED++))
test_service "NocoDB" "http://$SERVER_IP:8048" && ((SUCCESS++)) || ((FAILED++))
test_service "Vikunja" "http://$SERVER_IP:8049" && ((SUCCESS++)) || ((FAILED++))
test_service "Leantime" "http://$SERVER_IP:8050" && ((SUCCESS++)) || ((FAILED++))

echo ""
echo "## VOICE & DOCUMENTS"
echo "-----------------------------------"
test_service "Scriberr" "http://$SERVER_IP:8083" && ((SUCCESS++)) || ((FAILED++))
test_service "Stirling-PDF" "http://$SERVER_IP:8086" && ((SUCCESS++)) || ((FAILED++))

echo ""
echo "## SEARCH & DISCOVERY"
echo "-----------------------------------"
test_service "SearXNG" "http://$SERVER_IP:8089" && ((SUCCESS++)) || ((FAILED++))
test_service "Perplexica" "http://$SERVER_IP:8090" && ((SUCCESS++)) || ((FAILED++))
test_service "Crawl4AI" "http://$SERVER_IP:8093" && ((SUCCESS++)) || ((FAILED++))

echo ""
echo "## MONITORING"
echo "-----------------------------------"
test_service "Grafana" "http://$SERVER_IP:8003" && ((SUCCESS++)) || ((FAILED++))
test_service "Prometheus" "http://$SERVER_IP:8004/metrics" && ((SUCCESS++)) || ((FAILED++))
test_service "Portainer" "http://$SERVER_IP:8007" && ((SUCCESS++)) || ((FAILED++))
test_service "Langfuse" "http://$SERVER_IP:8096" && ((SUCCESS++)) || ((FAILED++))

echo ""
echo "## UTILITIES"
echo "-----------------------------------"
test_service "Mailpit" "http://$SERVER_IP:8071" && ((SUCCESS++)) || ((FAILED++))
test_service "Postiz" "http://$SERVER_IP:8060" && ((SUCCESS++)) || ((FAILED++))
test_service "Vaultwarden" "http://$SERVER_IP:8061" && ((SUCCESS++)) || ((FAILED++))
test_service "Kopia" "http://$SERVER_IP:8062" && ((SUCCESS++)) || ((FAILED++))
test_service "LibreTranslate" "http://$SERVER_IP:8082" && ((SUCCESS++)) || ((FAILED++))

echo ""
echo "## DEVELOPER APIs"
echo "-----------------------------------"
test_service "Ollama API" "http://$SERVER_IP:8021/api/tags" && ((SUCCESS++)) || ((FAILED++))
test_service "Weaviate API" "http://$SERVER_IP:8027/v1/schema" && ((SUCCESS++)) || ((FAILED++))
test_service "Qdrant API" "http://$SERVER_IP:8026" && ((SUCCESS++)) || ((FAILED++))
test_service "Whisper API" "http://$SERVER_IP:8080/docs" && ((SUCCESS++)) || ((FAILED++))
test_service "OpenedAI TTS" "http://$SERVER_IP:8081" && ((SUCCESS++)) || ((FAILED++))
test_service "Chatterbox TTS" "http://$SERVER_IP:8087/health" && ((SUCCESS++)) || ((FAILED++))
test_service "Gotenberg" "http://$SERVER_IP:8094/health" && ((SUCCESS++)) || ((FAILED++))
test_service "Tesseract OCR" "http://$SERVER_IP:8084/status" && ((SUCCESS++)) || ((FAILED++))
test_service "EasyOCR" "http://$SERVER_IP:8085/health" && ((SUCCESS++)) || ((FAILED++))
test_service "PostgreSQL" "http://$SERVER_IP:8001" 2 && ((SUCCESS++)) || ((FAILED++))
test_service "Redis" "http://$SERVER_IP:8002" 2 && ((SUCCESS++)) || ((FAILED++))
test_service "ClickHouse" "http://$SERVER_IP:8097/ping" && ((SUCCESS++)) || ((FAILED++))
test_service "MinIO API" "http://$SERVER_IP:8098/minio/health/live" && ((SUCCESS++)) || ((FAILED++))
test_service "MinIO Console" "http://$SERVER_IP:8099" && ((SUCCESS++)) || ((FAILED++))

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

if [ $FAILED -eq 0 ]; then
    echo "🎉 ALL SERVICES OPERATIONAL!"
    exit 0
else
    echo "⚠️  Some services need attention"
    echo ""
    echo "💡 Common fixes:"
    echo "   - Check .env quotes: grep '=\"' .env"
    echo "   - Restart failed: docker compose -p localai -f docker-compose.local.yml restart SERVICE_NAME"
    echo "   - View logs: docker logs SERVICE_NAME"
    exit 1
fi
