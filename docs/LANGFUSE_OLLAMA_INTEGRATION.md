# Langfuse + Ollama Integration Guide

## Table of Contents
- [What is Langfuse?](#what-is-langfuse)
- [Understanding Projects](#understanding-projects)
- [Initial Setup](#initial-setup)
- [Configuring Ollama Connection](#configuring-ollama-connection)
- [Integration Examples](#integration-examples)
- [Using the Dashboard](#using-the-dashboard)
- [Troubleshooting](#troubleshooting)

---

## What is Langfuse?

Langfuse is an open-source LLM observability platform that helps you monitor, debug, and optimize your AI applications.

### Why Use Langfuse?

**Performance Monitoring:**
- Track latency of every LLM call
- Identify slow prompts
- Monitor token usage
- Analyze response times

**Quality Assurance:**
- View exact prompts and responses
- Compare different model outputs
- Track errors and failures
- A/B test prompt variations

**Cost Analysis:**
- Calculate costs per request
- Track usage by user/workflow
- Optimize expensive calls
- With Ollama: Track as $0 but compare performance

**Debugging:**
- See full conversation history
- Trace errors to specific calls
- Replay failed requests
- Understand context

### Benefits for Local Stack

- ✅ **Complete Privacy:** All data stays on your server
- ✅ **No Cloud Costs:** Monitor unlimited Ollama calls for free
- ✅ **Real-time:** Live dashboard of LLM performance
- ✅ **Multi-Service:** Track n8n, Flowise, custom scripts from one place

---

## Understanding Projects

### Organization & Project Structure

```
📦 Organization: "My AI Lab"
   │
   ├─📁 Project: "n8n Workflows"
   │   ├─ 🔑 API Keys: pk-lf-n8n-xxx / sk-lf-n8n-xxx
   │   └─ 📊 Traces: All LLM calls from n8n
   │
   ├─📁 Project: "Flowise Agents"
   │   ├─ 🔑 API Keys: pk-lf-flow-xxx / sk-lf-flow-xxx
   │   └─ 📊 Traces: All LLM calls from Flowise
   │
   └─📁 Project: "Custom Scripts"
       ├─ 🔑 API Keys: pk-lf-custom-xxx / sk-lf-custom-xxx
       └─ 📊 Traces: Python/direct API calls
```

### Why Multiple Projects?

**Separation of Concerns:**
- **Different Applications:** n8n workflows vs Flowise agents
- **Different Teams:** Marketing workflows vs Development testing
- **Different Environments:** Production vs Testing

**Benefits:**
1. **Clear Analytics:** See n8n performance separately from Flowise
2. **Access Control:** Grant team members access to specific projects only
3. **Better Organization:** Don't mix production traces with experiments
4. **Independent Dashboards:** Customize views per use case

### How Differentiation Works

**Through API Keys:**
```javascript
// n8n sends traces with n8n project key
Headers: { "Authorization": "Bearer sk-lf-n8n-xxx" }
→ Trace appears in "n8n Workflows" project

// Flowise sends traces with Flowise project key
Headers: { "Authorization": "Bearer sk-lf-flow-xxx" }
→ Trace appears in "Flowise Agents" project
```

**Even though both call the same Ollama:**
```
n8n → Ollama (qwen2.5:7b) → Response → Langfuse (n8n project)
Flowise → Ollama (qwen2.5:7b) → Response → Langfuse (Flowise project)
```

Same model, different projects = separate tracking!

---

## Initial Setup

### Step 1: First Login

1. **Access Langfuse:**
   ```
   http://SERVER_IP:8096
   ```

2. **Login with Installation Credentials:**
   - Email: The email you configured during installation
   - Password: The password you set in the wizard
   
   **If you forgot:**
   ```bash
   # On your Ubuntu server:
   cd ~/ai/ai-launchkit-local
   grep "ADMIN_EMAIL\|ADMIN_PASSWORD" .env
   ```

3. **Complete Onboarding:**
   - Organization name: e.g., "My AI Lab"
   - First project name: e.g., "n8n Workflows"
   - Click through the introduction

### Step 2: Understanding the Interface

**Left Sidebar:**
- **Tracing:** View all LLM calls
- **Sessions:** Group related calls
- **Users:** Track per-user usage
- **Prompts:** Manage prompt templates
- **Datasets:** Test sets for evaluation
- **Scores:** Quality ratings

**Top Bar:**
- **Organization:** Switch organizations
- **Project:** Switch between projects

### Step 3: Create Projects

**Why Create Multiple Projects?**
- Separate n8n workflows from Flowise agents
- Different dashboards and metrics
- Clear separation of concerns

**How to Create a Project:**

1. Click **Organization dropdown** (top left)
2. Click **"+ New Project"**
3. Project name: e.g., "n8n Workflows"
4. Click **"Create"**

**Recommended Projects:**
```
1. "n8n Workflows"      - For all n8n automation
2. "Flowise Agents"     - For Flowise chatbots
3. "Development"        - For testing and experiments
4. "Custom Scripts"     - For Python/API integrations
```

### Step 4: Generate API Keys

**For Each Project:**

1. **Switch to Project:**
   - Top left dropdown → Select project

2. **Navigate to Settings:**
   - Click **Settings** (gear icon in sidebar)
   - Go to **"API Keys"** tab

3. **Create New Keys:**
   - Click **"+ Create new API keys"**
   - Name: Descriptive name (e.g., "n8n Production")
   
4. **Save Keys Securely:**
   ```
   Public Key:  pk-lf-1234567890abcdef...
   Secret Key:  sk-lf-0987654321fedcba...
   ```
   
   ⚠️ **Important:** Secret key is shown only once!
   
5. **Store in n8n:**
   - Save secret key in n8n credentials
   - Or in .env for reuse

---

## Configuring Ollama Connection

### Step 1: Navigate to LLM Connections

1. In Langfuse UI: **Settings** → **LLM Connections**
2. Click **"+ New LLM Connection"**

### Step 2: Basic Configuration

**Required Fields:**

| Field | Value | Notes |
|-------|-------|-------|
| **LLM adapter** | `openai` | Ollama uses OpenAI-compatible API |
| **Provider name** | `ollama` | Name to identify this connection |
| **API Key** | `dummy` | ⚠️ Cannot be empty (use "dummy" or any value) |

**Why "openai" adapter?**
- Ollama implements OpenAI's API specification
- Langfuse can use the same client library
- No special Ollama adapter needed

**Why API Key needed?**
- Langfuse validates the field is not empty
- Ollama doesn't actually check it
- Use any non-empty string (e.g., "dummy", "local", "ollama")

### Step 3: Advanced Settings

**Click "Hide advanced settings" to expand**

#### API Base URL (CRITICAL!)
```
http://ollama:11434/v1
```

**⚠️ Common Mistakes:**
- ❌ `http://ollama:11434` (missing /v1)
- ❌ `http://localhost:8021/v1` (wrong in Docker network)
- ❌ `http://SERVER_IP:8021/v1` (wrong in Docker network)
- ✅ `http://ollama:11434/v1` (CORRECT!)

**Why /v1?**
- Ollama's OpenAI-compatible API is at `/v1` endpoint
- Without it: 404 errors

**Why ollama:11434?**
- `ollama` is the Docker container hostname
- Services communicate via Docker internal network
- `localhost` doesn't work inside containers

#### Enable Default Models
```
☑️ ON (Toggle to enabled)
```

This allows Langfuse features to auto-detect available models.

#### Custom Models

**Click "+ Add custom model name" and add:**
```
qwen2.5:7b-instruct-q4_K_M
```

**To find exact model names:**
```bash
# On your Ubuntu server:
docker exec ollama ollama list
```

**Add all models you use:**
```
qwen2.5:7b-instruct-q4_K_M  (primary chat model)
nomic-embed-text            (embeddings)
```

### Step 4: Test Connection

1. Click **"Create connection"**
2. Langfuse will test the connection
3. **Success:** Green checkmark appears
4. **Failure:** Check troubleshooting section

---

## Integration Examples

### Example 1: n8n Workflow with Langfuse Tracing

**Scenario:** Track every Ollama call from your n8n workflows

#### Setup in n8n

**Method A: Using Langchain Node (Automatic)**

1. **Enable Langchain Tracing:**
   ```bash
   # Already configured in AI LaunchKit!
   # Check your .env has:
   LANGCHAIN_TRACING_V2=true
   LANGCHAIN_ENDPOINT=http://langfuse-web:3000
   LANGCHAIN_API_KEY=sk-lf-your-secret-key-here
   ```

2. **Use Langchain Node in Workflow:**
   - Add "Langchain Chat Model" node
   - Select Ollama as provider
   - Every call automatically traced!

3. **View in Langfuse:**
   - Go to Tracing tab
   - See all calls with full context

**Method B: Manual HTTP Request (More Control)**

```javascript
// After Ollama call in n8n workflow:

// HTTP Request Node to Langfuse:
Method: POST
URL: http://langfuse-web:3000/api/public/ingestion
Headers:
  Content-Type: application/json
  X-Auth-Token: {{ $credentials.langfuseSecret }}

Body:
{
  "batch": [{
    "type": "generation",
    "name": "Ollama Chat - {{ $workflow.name }}",
    "model": "qwen2.5:7b-instruct-q4_K_M",
    "input": {{ JSON.stringify($json.prompt) }},
    "output": {{ JSON.stringify($json.response) }},
    "metadata": {
      "workflow": "{{ $workflow.name }}",
      "node": "{{ $node.name }}",
      "executionId": "{{ $execution.id }}"
    },
    "usage": {
      "promptTokens": {{ $json.prompt_tokens || 0 }},
      "completionTokens": {{ $json.completion_tokens || 0 }}
    }
  }]
}
```

#### Complete Example Workflow

```
1. Webhook Trigger
   ↓
2. Ollama Chat (Generate response)
   ↓
3. HTTP Request (Send trace to Langfuse)
   ↓
4. Return Response
```

**Benefits:**
- See which workflows are slow
- Identify problematic prompts
- Track usage over time
- Optimize performance

### Example 2: Flowise Agent with Langfuse

**Scenario:** Track Flowise chatbot conversations

#### Setup in Flowise

1. **Go to Flowise Settings:**
   - Click gear icon (top right)
   - Navigate to "Langfuse" section

2. **Configure:**
   ```
   Langfuse Public Key:  pk-lf-flowise-xxx
   Langfuse Secret Key:  sk-lf-flowise-xxx
   Langfuse Host:        http://langfuse-web:3000
   ```

3. **Enable for Chatflow:**
   - Open your chatflow
   - Settings → Langfuse
   - Toggle **"Enable Langfuse"**

4. **Test:**
   - Send a message to chatbot
   - Check Langfuse for trace

**View in Langfuse:**
- Each conversation = Session
- Each message = Trace
- Full context preserved

---

## Using the Dashboard

### Viewing Traces

**Navigate to Tracing:**
1. Click **"Tracing"** in left sidebar
2. See list of all LLM calls

**Trace Details:**
Click any trace to see:
- **Input:** Exact prompt sent
- **Output:** Complete response
- **Metadata:** Workflow name, timestamps, etc.
- **Latency:** Time breakdown
- **Tokens:** Input/output token count
- **Cost:** Calculated cost (shows $0 for Ollama)

### Analyzing Performance

**Find Slow Calls:**
1. Tracing → Sort by "Latency"
2. Click slowest trace
3. See what made it slow (long prompt? complex response?)

**Most Used Prompts:**
1. Prompts tab
2. See which prompts are called most
3. Optimize frequently used ones

**Error Analysis:**
1. Filter by "Status: Error"
2. See what failed
3. Fix prompts causing issues

### Creating Custom Dashboards

**Built-in Dashboards:**
- Langfuse Latency Dashboard
- Langfuse Usage Management
- Langfuse Cost Dashboard

**Custom Dashboard:**
1. **Dashboards → "+ New Dashboard"**
2. **Add Widgets:**
   - P95 Latency by Model
   - Token Usage Over Time
   - Cost by Workflow
   - Error Rate

3. **Filter by:**
   - Time range
   - Model
   - Workflow name
   - User

### Example: Optimizing n8n Workflow

**Scenario:** Your n8n workflow is slow

1. **Find the Problem:**
   - Langfuse → Tracing
   - Sort by Latency (highest first)
   - Click slowest trace

2. **Analyze:**
   ```
   Prompt: "Summarize this 5000-word article..."
   Latency: 45 seconds
   Tokens: 6000 input, 500 output
   ```

3. **Optimize:**
   - Reduce input length (chunk the article)
   - Use faster model for summaries
   - Cache common summaries

4. **Measure Improvement:**
   - Run optimized version
   - Compare latencies in Langfuse
   - Track improvement over time

---

## Troubleshooting

### Connection Issues

**Error: "404 404 page not found"**

**Cause:** Missing `/v1` in API Base URL

**Solution:**
```
✅ Correct: http://ollama:11434/v1
❌ Wrong:   http://ollama:11434
```

---

**Error: "Cannot connect to Ollama"**

**Diagnosis:**
```bash
# 1. Check Ollama is running
docker ps | grep ollama

# 2. Test from Langfuse container
docker exec langfuse-web curl http://ollama:11434/v1/models

# Should return JSON with models list
```

**Solutions:**
- Ensure Ollama is running (cpu, gpu-nvidia, or gpu-amd profile)
- Check Docker network connectivity
- Verify URL uses container hostname `ollama`, not `localhost`

---

**Error: "API Key required"**

**Cause:** API Key field left empty

**Solution:**
- API Key cannot be empty (Langfuse validation)
- Enter any non-empty string: "dummy", "local", "ollama"
- Ollama doesn't validate it, so any value works

---

### Model Issues

**Error: "Model not found"**

**Cause:** Model name doesn't match exactly

**Solution:**
```bash
# Get exact model names:
docker exec ollama ollama list

# Use exact name from list, including tags:
qwen2.5:7b-instruct-q4_K_M  ✅
qwen2.5                      ❌ (too generic)
qwen2                        ❌ (wrong version)
```

---

**Error: "Model not available"**

**Cause:** Model not loaded in Ollama

**Solution:**
```bash
# Load the model:
docker exec ollama ollama pull qwen2.5:7b-instruct-q4_K_M

# Verify it's loaded:
docker exec ollama ollama list
```

---

### Tracing Issues

**No traces appearing in Langfuse**

**Checklist:**
1. ✅ Correct API keys in n8n/Flowise?
2. ✅ Langfuse URL correct: `http://langfuse-web:3000`?
3. ✅ Project selected (top left)?
4. ✅ Workflow actually called Ollama?

**Debug:**
```bash
# Check Langfuse logs for incoming requests:
docker logs langfuse-web --tail 50 | grep "ingestion"

# Should show POST requests when traces arrive
```

---

**Traces in wrong project**

**Cause:** Using wrong API keys

**Solution:**
- Each project has unique API keys
- Check which key you're using in n8n/Flowise
- Switch to correct project in Langfuse UI

---

### Performance Issues

**Langfuse UI is slow**

**Solutions:**
```bash
# 1. Reduce trace retention (if many traces)
# In Langfuse: Settings → Data Retention

# 2. Increase Docker memory
# In docker-compose.local.yml increase langfuse-web memory limit

# 3. Check ClickHouse performance
docker stats clickhouse
```

---

**Traces not showing immediately**

**Normal behavior:**
- Traces can take 1-2 seconds to appear
- ClickHouse batches writes for performance
- Refresh the page if needed

---

## Resources

**Langfuse Documentation:**
- Official Docs: https://langfuse.com/docs
- n8n Integration: https://langfuse.com/docs/integrations/langchain/example-n8n
- Flowise Integration: https://langfuse.com/docs/integrations/flowise

**Your Local Services:**
- Langfuse UI: http://SERVER_IP:8096
- Ollama API: http://SERVER_IP:8021
- n8n: http://SERVER_IP:8000
- Flowise: http://SERVER_IP:8022

**Community:**
- Langfuse GitHub: https://github.com/langfuse/langfuse
- Discord: https://langfuse.com/discord

---

## Quick Reference

### Langfuse Ollama Connection Settings

```yaml
LLM adapter:       openai
Provider name:     ollama
API Key:           dummy
API Base URL:      http://ollama:11434/v1
Custom models:     qwen2.5:7b-instruct-q4_K_M
                   nomic-embed-text
```

### Common Commands

```bash
# Check Ollama models
docker exec ollama ollama list

# Test Ollama API
curl http://localhost:8021/api/tags

# Check Langfuse logs
docker logs langfuse-web --tail 50

# Restart Langfuse
docker compose -p localai -f docker-compose.local.yml restart langfuse-web

# View Langfuse API keys in .env
grep "LANGFUSE" .env
```

---

## Next Steps

1. **Create Projects:** One for each service (n8n, Flowise, etc.)
2. **Generate API Keys:** For each project
3. **Configure Services:** Add Langfuse keys to n8n, Flowise
4. **Test:** Make some LLM calls and check traces
5. **Build Dashboards:** Create custom views for your use case
6. **Set Up Alerts:** Get notified of high latency or errors

---

**Last Updated:** 2025-10-07

For issues specific to the AI LaunchKit Local setup:
- [Report Issues](https://github.com/hermannheinrich/ai-launchkit-local/issues)
- [Documentation](../README.md)
