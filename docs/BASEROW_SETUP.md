# Baserow Integration Guide

## Table of Contents
- [What is Baserow?](#what-is-baserow)
- [Understanding Workspaces](#understanding-workspaces)
- [Initial Setup](#initial-setup)
- [Creating Your First Database](#creating-your-first-database)
- [Integration Examples](#integration-examples)
- [Using the Interface](#using-the-interface)
- [Troubleshooting](#troubleshooting)

---

## What is Baserow?

Baserow is an open-source no-code database platform that combines the simplicity of spreadsheets with the power of databases. Think of it as a self-hosted Airtable alternative.

### Why Use Baserow?

**Structured Data for AI:**
- Store AI-generated data in organized tables
- Build datasets for RAG (Retrieval Augmented Generation)
- Track AI workflow results
- Create feedback loops for AI improvement

**No-Code Database:**
- Visual interface like spreadsheets
- Powerful database features (relations, formulas, etc.)
- REST API for every table automatically
- Real-time collaboration

**Automation Ready:**
- Direct integration with n8n workflows
- API endpoints for every table
- Webhooks for data changes
- Import/Export via CSV, JSON

**Complete Privacy:**
- All data stays on your server
- No cloud dependency
- Full control over your data
- GDPR-compliant

### Benefits for Local Stack

- ✅ **Visual Data Management:** Manage AI data without SQL
- ✅ **n8n Integration:** Direct nodes for CRUD operations
- ✅ **API-First:** Every table is automatically an API
- ✅ **Team Collaboration:** Multiple users, real-time updates
- ✅ **Forms:** Create public forms to collect data
- ✅ **Views:** Multiple views of same data (Grid, Gallery, Kanban, Calendar)

### Typical Use Cases in AI LaunchKit

1. **AI Training Data Management**
   - Store prompts and responses for fine-tuning
   - Track model performance metrics
   - Organize test datasets

2. **Customer Interaction Tracking**
   - Log chatbot conversations
   - Track user feedback
   - Store support tickets

3. **Content Pipeline**
   - Manage blog post queue
   - Track social media content
   - Store AI-generated assets

4. **Project Management**
   - Track AI experiment results
   - Manage feature requests
   - Document workflows

---

## Understanding Workspaces

### Workspace & Application Structure

```
🏢 Workspace: "My AI Projects"
   │
   ├─📊 Application: "Customer Feedback"
   │   ├─ 📋 Table: "Conversations"
   │   ├─ 📋 Table: "Sentiment Analysis"
   │   └─ 📋 Table: "Topics"
   │
   ├─📊 Application: "Content Pipeline"
   │   ├─ 📋 Table: "Blog Posts"
   │   ├─ 📋 Table: "Social Media"
   │   └─ 📋 Table: "Assets"
   │
   └─📊 Application: "Training Data"
       ├─ 📋 Table: "Prompts"
       ├─ 📋 Table: "Responses"
       └─ 📋 Table: "Evaluations"
```

### Why Multiple Workspaces?

**Organization:**
- **Workspace 1:** Production data
- **Workspace 2:** Testing/Development
- **Workspace 3:** Personal projects

**Access Control:**
- Grant team members access to specific workspaces
- Different permissions per workspace
- Separate sensitive data

**Benefits:**
1. **Clean Separation:** Production vs testing data
2. **Team Management:** Control who sees what
3. **Better Organization:** Group related applications
4. **Independent APIs:** Each table has unique API endpoint

---

## Initial Setup

### Step 1: First Access

1. **Access Baserow:**
   ```
   http://SERVER_IP:8047
   ```

2. **First-Time Registration:**
   
   When you first access Baserow, you'll see a sign-up form:
   
   - **Full Name:** e.g., "Heinrich Administrator"
   - **Email:** e.g., "admin@localhost" or your email
   - **Password:** Choose a strong password
   
   ⚠️ **Important:** 
   - The first registered user automatically becomes **Admin**
   - This account has full access to all workspaces
   - Store credentials securely (consider using Vaultwarden at port 8061)

3. **Welcome Screen:**
   - Baserow shows a quick tutorial
   - Click through or skip
   - You'll land on the main dashboard

### Step 2: Understanding the Interface

**Top Navigation:**
- **Logo (left):** Return to dashboard
- **Workspace dropdown:** Switch between workspaces
- **Search:** Find tables and rows quickly
- **User menu (right):** Settings, profile, logout

**Left Sidebar:**
- **Applications:** List of all databases in current workspace
- **Trash:** Recently deleted items
- **Templates:** Pre-built database templates (if enabled)

**Main Area:**
- **Tables:** Your data in spreadsheet view
- **Views:** Different ways to see same data (Grid, Gallery, Form, Kanban)

### Step 3: Create Your First Workspace

**Default Workspace:**
- Baserow creates a default workspace automatically
- Name: Usually "Workspace 1" or your name

**Create Additional Workspace:**

1. Click **Workspace dropdown** (top left)
2. Click **"+ New workspace"**
3. Enter name: e.g., "AI Production"
4. Click **"Create workspace"**

**Workspace Settings:**
- Click **⚙️** next to workspace name
- Manage members, permissions, settings
- Delete or rename workspace

### Step 4: Invite Team Members (Optional)

1. **Workspace Settings:**
   - Click ⚙️ next to workspace name
   - Go to **"Members"** tab

2. **Invite User:**
   - Click **"+ Invite member"**
   - Enter email address
   - Select role:
     - **Admin:** Full access
     - **Member:** Can edit
     - **Viewer:** Read-only

3. **Email Notification:**
   - User receives email via Mailpit (port 8071)
   - Check Mailpit UI to see invitation
   - Copy invitation link from email

⚠️ **Note:** Email delivery uses Mailpit (local mail catcher), so invited users need the link from Mailpit UI.

---

## Creating Your First Database

### Quick Start: Using a Template

**If templates are enabled:**

1. **Dashboard → "+ New application"**
2. **"Use template"** tab
3. Browse templates:
   - CRM (Customer Relationship Management)
   - Project Tracker
   - Content Calendar
   - Task Management
4. Click template → "Use template" → Customize

### Creating from Scratch

1. **Click "+ New application"**
2. **"Start from scratch"** tab
3. **Name your application:** e.g., "AI Conversations"
4. **Click "Create application"**

### Creating Tables

**Method 1: Blank Table**

1. Inside application → **"+ Add table"**
2. Name: e.g., "Customer Chats"
3. Baserow creates with default fields:
   - Name (Text)
   - Notes (Long Text)
   - Active (Boolean)

**Method 2: Import Data**

1. **"+ Add table" → "Import"**
2. Upload file:
   - CSV
   - JSON
   - XML
3. Map columns
4. Import

### Designing Your Schema

**Common Field Types for AI Applications:**

| Field Type | Use Case | Example |
|------------|----------|---------|
| **Long Text** | Prompts, responses | AI-generated content |
| **Single Select** | Categories | "Positive", "Negative", "Neutral" |
| **Multi Select** | Tags | "urgent", "reviewed", "processed" |
| **Number** | Metrics | Token count, latency, cost |
| **Date** | Timestamps | Created at, processed at |
| **Link to Table** | Relations | Link conversation to user |
| **File** | Attachments | Audio files, images, PDFs |
| **Formula** | Calculations | Cost = tokens * price_per_token |
| **URL** | Links | Source URL, reference links |

**Example: AI Conversation Tracking Table**

```
Table: "AI Conversations"
├─ ID (auto)
├─ Created At (Date)
├─ User Email (Email)
├─ Conversation (Long Text)
├─ AI Response (Long Text)
├─ Model Used (Single Select: "qwen2.5", "gpt-4", etc.)
├─ Token Count (Number)
├─ Latency (Number, in seconds)
├─ Sentiment (Single Select: "positive", "negative", "neutral")
├─ Tags (Multi Select)
└─ Source (Single Select: "n8n", "flowise", "api")
```

---

## Integration Examples

### Example 1: n8n Workflow with Baserow

**Scenario:** Log every AI conversation to Baserow for analysis

#### Setup in n8n

**Prerequisites:**
- Baserow running at http://baserow:80 (Docker internal) or http://localhost:8047 (external)
- Table created with appropriate fields

**Step-by-Step:**

1. **Get Baserow API Token:**
   - In Baserow: Click user menu (top right)
   - **"Settings" → "API tokens"**
   - Click **"+ Create token"**
   - Name: "n8n Integration"
   - Copy token (starts with "dG...")

2. **Add Baserow Credentials in n8n:**
   - n8n → Credentials → "+ Add credential"
   - Search "Baserow"
   - **API Token:** Paste your token
   - **Host:** `http://baserow:80` (for Docker network)
   - Save as "Baserow Local"

3. **Create n8n Workflow:**

```
Workflow: "Log AI Conversations to Baserow"

1. Trigger: Webhook
   ↓
2. Ollama: Generate Response
   ↓
3. Baserow: Create Row
   Settings:
   - Credentials: Baserow Local
   - Database: Select your application
   - Table: "AI Conversations"
   - Fields to Set:
     * User Email: {{ $json.email }}
     * Conversation: {{ $json.input }}
     * AI Response: {{ $('Ollama').item.json.response }}
     * Model Used: "qwen2.5"
     * Token Count: {{ $('Ollama').item.json.tokens }}
     * Created At: {{ $now }}
   ↓
4. Respond to Webhook
```

4. **Test the Workflow:**
   - Send test webhook
   - Check Baserow table for new row
   - All data should appear instantly!

#### Advanced: Sentiment Analysis Pipeline

```
Workflow: "AI Conversation with Sentiment"

1. Webhook Trigger (receives user message)
   ↓
2. Ollama: Generate Response
   ↓
3. Ollama: Analyze Sentiment
   Prompt: "Analyze sentiment of this conversation: [...]"
   ↓
4. Baserow: Create Row
   - Conversation
   - Response
   - Sentiment (from step 3)
   - Tags (extracted keywords)
   ↓
5. IF Sentiment = "negative"
   → Send Slack alert to support team
   ↓
6. Return Response
```

**Benefits:**
- Automatic logging of all conversations
- Sentiment trends visible in Baserow
- Support team notified of issues
- Historical data for AI improvements

### Example 2: Flowise with Baserow Integration

**Scenario:** Use Baserow as knowledge base for Flowise chatbot

#### Method A: Using Baserow Data in RAG

1. **Export Baserow Table:**
   - Open table in Baserow
   - Top right → "..." → "Export"
   - Format: JSON or CSV

2. **In Flowise:**
   - Add "Document Loaders" → "CSV File"
   - Upload exported Baserow data
   - Add to Vector Store
   - Connect to Conversational Agent

3. **Keep Updated:**
   - Schedule n8n workflow:
   - Every hour: Export from Baserow → Update Flowise vector store

#### Method B: Direct API Calls from Flowise

**Using Custom Tool in Flowise:**

```javascript
// Custom Tool: "Query Baserow CRM"
const axios = require('axios');

const queryBaserow = async (searchTerm) => {
  const response = await axios.get(
    'http://baserow:80/api/database/rows/table/YOUR_TABLE_ID/',
    {
      headers: {
        'Authorization': 'Token YOUR_BASEROW_TOKEN'
      },
      params: {
        'search': searchTerm
      }
    }
  );
  return response.data.results;
};
```

**Use Case:**
- User asks chatbot: "What's the status of order #123?"
- Flowise calls Baserow API
- Returns real-time data from your CRM table
- Formats response with AI

### Example 3: Python Script Integration

**Scenario:** Automated data processing with Baserow storage

```python
import requests
import os

# Baserow Configuration
BASEROW_URL = "http://localhost:8047"
BASEROW_TOKEN = os.getenv("BASEROW_API_TOKEN")
TABLE_ID = 12345  # Your table ID

# Headers for authentication
headers = {
    "Authorization": f"Token {BASEROW_TOKEN}",
    "Content-Type": "application/json"
}

# Create a row
def create_row(data):
    url = f"{BASEROW_URL}/api/database/rows/table/{TABLE_ID}/"
    response = requests.post(url, json=data, headers=headers)
    return response.json()

# Read rows with filter
def get_rows(filter_value):
    url = f"{BASEROW_URL}/api/database/rows/table/{TABLE_ID}/"
    params = {
        "search": filter_value,
        "size": 100
    }
    response = requests.get(url, params=params, headers=headers)
    return response.json()["results"]

# Update a row
def update_row(row_id, data):
    url = f"{BASEROW_URL}/api/database/rows/table/{TABLE_ID}/{row_id}/"
    response = requests.patch(url, json=data, headers=headers)
    return response.json()

# Example: Log AI conversation
conversation_data = {
    "User Email": "user@example.com",
    "Conversation": "What's the weather?",
    "AI Response": "I don't have access to weather data.",
    "Model Used": "qwen2.5",
    "Token Count": 45,
    "Sentiment": "neutral"
}

result = create_row(conversation_data)
print(f"Created row with ID: {result['id']}")
```

### Example 4: Building a RAG System with Baserow

**Scenario:** Store and retrieve company knowledge base

#### Architecture:

```
Knowledge Base (Baserow)
    ↓
Export via API
    ↓
Chunk & Embed (n8n workflow)
    ↓
Store in Qdrant
    ↓
Query from Flowise/n8n
```

#### Implementation:

**1. Create Knowledge Base in Baserow:**

Table: "Knowledge Base"
- Title (Text)
- Content (Long Text)
- Category (Single Select)
- Tags (Multi Select)
- Last Updated (Date)
- Source URL (URL)

**2. n8n Workflow: "Sync Baserow to Qdrant"**

```
Schedule: Daily at 2 AM
    ↓
Baserow: Get All Rows (filter: updated today)
    ↓
Split into Chunks (500 tokens each)
    ↓
Ollama: Generate Embeddings (nomic-embed-text)
    ↓
Qdrant: Upsert Vectors
    ↓
Done: Knowledge base updated!
```

**3. Query in Flowise:**
- User asks question
- Search Qdrant for relevant chunks
- Retrieve original Baserow row IDs
- Use context to generate answer
- Include Baserow sources in response

**Benefits:**
- ✅ Visual knowledge management
- ✅ Automatic embedding updates
- ✅ Source attribution
- ✅ Easy content updates (just edit in Baserow)

---

## Using the Interface

### Views: Different Perspectives on Data

**Grid View (Default):**
- Spreadsheet-like interface
- Sort, filter, group rows
- Bulk edit capabilities
- Best for: Data entry, analysis

**Gallery View:**
- Card-based display
- Show image fields prominently
- Best for: Product catalogs, portfolios

**Form View:**
- Public data collection forms
- Customizable fields
- Share via URL
- Best for: Surveys, applications, user feedback

**Kanban View:**
- Drag-and-drop boards
- Group by Single Select field
- Best for: Project management, pipelines

**Calendar View:**
- Timeline visualization
- Group by date fields
- Best for: Events, scheduling, deadlines

### Creating Views

1. **Click "+" next to "Grid" (top left of table)**
2. **Select view type**
3. **Configure:**
   - Name the view
   - Choose grouping/sorting
   - Set filters
4. **Share:**
   - Public link (optional)
   - Embed in website
   - Password protection

### Using Filters

**Create Smart Views:**

Example: "Urgent Feedback"
```
Filter: 
  Sentiment = "negative" 
  AND Status = "new"
  AND Created At > 7 days ago

Sort by: Created At (descending)
```

**Access:**
- Only shows urgent items
- Auto-updates as data changes
- Share view with support team

### Formulas

**Calculate Fields:**

```javascript
// Calculate AI response quality score
if(field('Sentiment') = 'positive', 100, 
   if(field('Sentiment') = 'neutral', 50, 0)) 
+ field('Token Count') / 10

// Format full conversation
concat(
  'User: ', field('User Message'), '\n',
  'AI: ', field('AI Response')
)

// Check if conversation needs review
if(field('Token Count') > 1000, '⚠️ Long conversation', '✅ Normal')
```

### API Usage

**Get Table ID:**
1. Open table in Baserow
2. Look at URL: `...applications/123/table/456/`
3. Table ID = `456`

**Get Database ID:**
1. URL shows: `...applications/123/...`
2. Database ID = `123`

**API Base URL:**
```
Internal (from Docker): http://baserow:80/api/
External: http://localhost:8047/api/
Network: http://192.168.178.151:8047/api/
```

**Common Endpoints:**

```bash
# List all rows
GET /api/database/rows/table/{table_id}/
Headers: Authorization: Token YOUR_TOKEN

# Create row
POST /api/database/rows/table/{table_id}/
Headers: Authorization: Token YOUR_TOKEN
Body: { "field_123": "value", "field_456": "value" }

# Get single row
GET /api/database/rows/table/{table_id}/{row_id}/

# Update row
PATCH /api/database/rows/table/{table_id}/{row_id}/
Body: { "field_123": "new_value" }

# Delete row
DELETE /api/database/rows/table/{table_id}/{row_id}/

# Search/Filter
GET /api/database/rows/table/{table_id}/?search=keyword
GET /api/database/rows/table/{table_id}/?filter__field_123__equal=value
```

**Field Names in API:**
- In Baserow UI: "User Email"
- In API: `field_123` (numeric field ID)
- Get field IDs from: `/api/database/fields/table/{table_id}/`

---

## Integration Examples with AI LaunchKit Services

### 1. Baserow + n8n: Customer Feedback Loop

**Workflow:** Collect feedback → Analyze with AI → Store in Baserow → Alert team

```
Workflow: "AI-Powered Feedback Analysis"

1. Webhook: Receive feedback form submission
   ↓
2. Ollama: Analyze sentiment and extract topics
   Prompt: "Analyze this feedback: {{ $json.message }}"
   ↓
3. Baserow: Create Row in "Customer Feedback"
   - User Email
   - Feedback Text
   - Sentiment (from AI)
   - Topics (from AI)
   - Status: "new"
   ↓
4. IF Sentiment = "very negative":
   → Slack: Alert support team
   → Baserow: Update Status to "urgent"
```

### 2. Baserow + Flowise: Dynamic FAQ Bot

**Setup:**
1. **Create FAQ Table in Baserow:**
   - Question (Text)
   - Answer (Long Text)
   - Category (Single Select)
   - Keywords (Multi Select)

2. **Export to JSON** (manual or via n8n)

3. **In Flowise:**
   - Document Loader: Load FAQ JSON
   - Text Splitter: Chunk by question
   - Embeddings: nomic-embed-text via Ollama
   - Vector Store: Qdrant
   - Retrieval QA Chain: Answer from FAQ

4. **Auto-Update:**
   - n8n workflow runs nightly
   - Exports Baserow FAQs
   - Updates Flowise vector store

### 3. Baserow + Ollama: Content Generation Pipeline

**Workflow:** Generate blog posts → Store in Baserow → Review → Publish

```
Workflow: "AI Content Pipeline"

1. Schedule: Every Monday 9 AM
   ↓
2. Baserow: Get Rows where Status = "topic_approved"
   ↓
3. For each topic:
   a. Ollama: Generate blog post outline
   b. Ollama: Write introduction
   c. Ollama: Write main content (3 sections)
   d. Ollama: Write conclusion
   e. Combine all parts
   ↓
4. Baserow: Update Row
   - Generated Content (Long Text)
   - Status: "needs_review"
   - Generated At: {{ $now }}
   ↓
5. Email: Notify editor to review
```

**Benefits:**
- ✅ Visual pipeline management
- ✅ Manual review step before publishing
- ✅ Version history in Baserow
- ✅ Collaborative editing

### 4. Baserow + Python: Automated Data Processing

**Use Case:** Process daily AI analytics

```python
#!/usr/bin/env python3
"""
Daily AI Analytics Processor
Reads data from Baserow, processes with pandas, updates results
"""

import requests
import pandas as pd
from datetime import datetime, timedelta

BASEROW_URL = "http://localhost:8047"
BASEROW_TOKEN = "YOUR_TOKEN_HERE"
SOURCE_TABLE = 12345  # AI Conversations table
RESULTS_TABLE = 12346  # Daily Analytics table

def get_yesterdays_conversations():
    """Fetch conversations from yesterday"""
    yesterday = (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")
    
    url = f"{BASEROW_URL}/api/database/rows/table/{SOURCE_TABLE}/"
    params = {
        "filter__field_12__date_after": yesterday,
        "size": 1000
    }
    headers = {"Authorization": f"Token {BASEROW_TOKEN}"}
    
    response = requests.get(url, params=params, headers=headers)
    return response.json()["results"]

def analyze_conversations(conversations):
    """Calculate metrics"""
    df = pd.DataFrame(conversations)
    
    metrics = {
        "Date": datetime.now().strftime("%Y-%m-%d"),
        "Total Conversations": len(df),
        "Positive Sentiment": len(df[df["field_8"] == "positive"]),
        "Negative Sentiment": len(df[df["field_8"] == "negative"]),
        "Avg Token Count": df["field_10"].mean(),
        "Avg Latency": df["field_11"].mean(),
        "Most Used Model": df["field_9"].mode()[0]
    }
    
    return metrics

def save_to_baserow(metrics):
    """Store results in analytics table"""
    url = f"{BASEROW_URL}/api/database/rows/table/{RESULTS_TABLE}/"
    headers = {
        "Authorization": f"Token {BASEROW_TOKEN}",
        "Content-Type": "application/json"
    }
    
    # Map to Baserow field IDs
    row_data = {
        "field_1": metrics["Date"],
        "field_2": metrics["Total Conversations"],
        "field_3": metrics["Positive Sentiment"],
        "field_4": metrics["Negative Sentiment"],
        "field_5": round(metrics["Avg Token Count"], 2),
        "field_6": round(metrics["Avg Latency"], 2),
        "field_7": metrics["Most Used Model"]
    }
    
    response = requests.post(url, json=row_data, headers=headers)
    return response.json()

# Run the pipeline
conversations = get_yesterdays_conversations()
metrics = analyze_conversations(conversations)
result = save_to_baserow(metrics)
print(f"✅ Analytics saved: {metrics['Total Conversations']} conversations processed")
```

**Run with Cron:**
```bash
# Add to crontab on your server
0 1 * * * cd ~/ai/scripts && python3 daily_baserow_analytics.py
```

### 5. Baserow Forms: Public Data Collection

**Scenario:** Collect AI feature requests from users

1. **Create Table:** "Feature Requests"
   - Name (Text)
   - Email (Email)  
   - Feature Description (Long Text)
   - Use Case (Long Text)
   - Priority (Single Select)
   - Submitted At (Date)

2. **Create Form View:**
   - Click "+ Add view" → "Form"
   - Name: "Submit Feature Request"
   - Configure fields:
     - Show: Name, Email, Description, Use Case
     - Hide: Priority, Submitted At (auto-filled)

3. **Share Form:**
   - Click "Share view" → "Create public link"
   - Copy URL: `http://192.168.178.151:8047/form/xyz123`
   - Share with users

4. **Process Submissions:**
   - New submissions appear in table automatically
   - Manually set priority
   - Integrate with n8n for auto-processing:
     ```
     Baserow Webhook → Ollama Analysis → Auto-categorize → Slack notification
     ```

---

## Troubleshooting

### Connection Issues

**Error: "Seite nicht gefunden" (Page not found)**

**Diagnosis:**
```bash
# Check if Baserow is running
docker ps | grep baserow

# Check logs
docker logs baserow --tail 50

# Test health endpoint
curl http://localhost:8047/api/_health/
```

**Solutions:**
- Wait 2 minutes after restart for full initialization
- Check Baserow is in your COMPOSE_PROFILES
- Verify .env has BASEROW_SECRET_KEY set

---

**Error: "ERR ERR ERR" in logs**

**Cause:** Caddy reverse proxy issues (fixed in updated config)

**Solution:**
Already fixed in docker-compose.local.yml:
- Template sync disabled: `BASEROW_TRIGGER_SYNC_TEMPLATES_AFTER_MIGRATION=false`
- Extended healthcheck: `start_period: 120s`
- Caddy configured: `BASEROW_CADDY_ADDRESSES=:80`

**Verify fix:**
```bash
docker logs baserow 2>&1 | grep -c "ERR ERR ERR"
# Should return 0 or very small number
```

---

**Error: "Database connection failed"**

**Diagnosis:**
```bash
# Check PostgreSQL is healthy
docker ps | grep postgres

# Test from Baserow container
docker exec baserow curl postgres:5432
```

**Solutions:**
- Ensure PostgreSQL started before Baserow
- Check POSTGRES_PASSWORD matches in .env
- Verify DATABASE_URL is correct

---

### Authentication Issues

**Cannot login after registration**

**Cause:** Email not confirmed (if email verification enabled)

**Solution:**
1. Check Mailpit for verification email:
   ```
   http://localhost:8071
   ```

2. Click verification link in email

3. Or disable email verification:
   ```yaml
   # In docker-compose.local.yml:
   - EMAIL_VERIFICATION_DISABLED=1
   ```

---

**Forgot password**

**Solution:**

1. **Via UI:**
   - Login page → "Forgot password?"
   - Check Mailpit (port 8071) for reset email

2. **Via Command Line:**
   ```bash
   # Reset password via Django management
   docker exec -it baserow bash
   
   # Inside container:
   cd /baserow/backend
   python src/baserow/manage.py changepassword user@email.com
   ```

---

### API Issues

**Error: "401 Unauthorized"**

**Cause:** Invalid or missing API token

**Solution:**
1. Generate new token in Baserow UI:
   - User menu → Settings → API tokens
   - Create new token
   - Copy and use in requests

2. Verify token format:
   ```bash
   # Correct format:
   Authorization: Token dG9rZW46YWJjZGVmMTIzNDU2...
   
   # NOT:
   Authorization: Bearer YOUR_TOKEN  ❌
   ```

---

**Error: "Field not found"**

**Cause:** Using field name instead of field ID

**Solution:**
```bash
# Get field IDs for your table:
curl -H "Authorization: Token YOUR_TOKEN" \
  http://localhost:8047/api/database/fields/table/TABLE_ID/

# Response shows:
{
  "id": 123,
  "name": "User Email",
  "type": "email"
}

# Use in API: "field_123" not "User Email"
```

---

### Performance Issues

**Baserow slow to start**

**Cause:** Template sync enabled (124 templates!)

**Solution:**
Already fixed in docker-compose.local.yml:
```yaml
- BASEROW_TRIGGER_SYNC_TEMPLATES_AFTER_MIGRATION=false
```

**If you need templates:**
```yaml
# Enable once, let it sync (5-10 minutes), then disable again
- BASEROW_TRIGGER_SYNC_TEMPLATES_AFTER_MIGRATION=true
```

---

**Large tables loading slowly**

**Solutions:**
1. **Use pagination in API:**
   ```bash
   GET /api/database/rows/table/123/?size=100&page=2
   ```

2. **Create filtered views:**
   - Don't load all 10,000 rows
   - Filter to recent data only
   - Use search for specific records

3. **Add database indexes:**
   - Baserow auto-indexes primary keys
   - Consider field types (Number faster than Text for filtering)

---

**Real-time updates delayed**

**Cause:** WebSocket connection issues

**Diagnosis:**
```bash
# Check if WebSocket is working
# In browser console (F12):
# Should see WebSocket connection in Network tab
```

**Solution:**
- Refresh the page
- Check firewall isn't blocking WebSocket connections
- Verify `privileged: true` in docker-compose.yml (allows WebSocket)

---

### Import/Export Issues

**Import fails: "Invalid format"**

**Solutions:**
1. **CSV Requirements:**
   - UTF-8 encoding
   - Comma or semicolon separator
   - Header row required

2. **Field Mapping:**
   - Review column mapping screen carefully
   - Ensure date formats match (YYYY-MM-DD)
   - Check number fields don't have text

3. **Size Limits:**
   - Max 1 TB file size (default)
   - If larger: Import in chunks

**Export taking long time**

**Expected:** Large tables (>10,000 rows) take time

**Progress:**
- Baserow shows export job progress
- Download link appears when ready
- Check background jobs in Baserow settings

---

## Resources

**Baserow Documentation:**
- Official Docs: https://baserow.io/docs
- API Reference: https://baserow.io/docs/apis/rest-api
- n8n Integration: https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.baserow/

**Your Local Services:**
- Baserow UI: http://SERVER_IP:8047
- Mailpit (for emails): http://SERVER_IP:8071
- n8n (for automation): http://SERVER_IP:8000
- Flowise (for AI agents): http://SERVER_IP:8022
- Qdrant (for vectors): http://SERVER_IP:8026

**Pre-built Workflows:**
- AI Data Extraction with Baserow: `/n8n/backup/workflows/AI Data Extraction with Dynamic Prompts and Baserow.json`

**Community:**
- Baserow GitHub: https://github.com/baserow/baserow
- Community Forum: https://community.baserow.io/
- Discord: https://discord.com/invite/WgJAJgm

---

## Quick Reference

### Baserow Configuration Settings

```yaml
# docker-compose.local.yml
BASEROW_PUBLIC_URL: http://localhost:8047
BASEROW_TRIGGER_SYNC_TEMPLATES_AFTER_MIGRATION: false
BASEROW_RUN_MINIMAL: yes
BASEROW_AMOUNT_OF_WORKERS: 1
BASEROW_CADDY_ADDRESSES: :80
```

### Common Commands

```bash
# Restart Baserow
cd ~/ai/ai-launchkit-local
docker compose -p localai -f docker-compose.local.yml restart baserow

# View logs
docker logs baserow --tail 100 --follow

# Check health
curl http://localhost:8047/api/_health/

# Access Baserow shell
docker exec -it baserow bash

# List Baserow environment
docker exec baserow env | grep BASEROW

# Full restart with git pull
cd ~/ai/ai-launchkit-local && \
git pull && \
docker compose -p localai -f docker-compose.local.yml down baserow baserow-init && \
docker compose -p localai -f docker-compose.local.yml up -d baserow
```

### API Quick Start

```bash
# Get your API token from Baserow UI first!
# Then test:

# List tables in database
curl -H "Authorization: Token YOUR_TOKEN" \
  http://localhost:8047/api/database/tables/database/DATABASE_ID/

# Get rows from table
curl -H "Authorization: Token YOUR_TOKEN" \
  http://localhost:8047/api/database/rows/table/TABLE_ID/

# Create a row
curl -X POST \
  -H "Authorization: Token YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"field_123": "value", "field_456": "value"}' \
  http://localhost:8047/api/database/rows/table/TABLE_ID/
```

### Integration Checklist

**Setting up n8n + Baserow:**
- [ ] Baserow running and accessible
- [ ] Table created with required fields
- [ ] API token generated in Baserow
- [ ] Baserow credentials added to n8n
- [ ] Test workflow created
- [ ] Workflow tested successfully

**Setting up Flowise + Baserow:**
- [ ] Baserow table with knowledge base
- [ ] Data exported (JSON/CSV)
- [ ] Flowise document loader configured
- [ ] Vector embeddings created
- [ ] Chatbot tested with Baserow data

**Setting up Python + Baserow:**
- [ ] API token secured (environment variable)
- [ ] Table and field IDs documented
- [ ] Python script tested
- [ ] Error handling implemented
- [ ] Cron job scheduled (if needed)

---

## Next Steps

1. **Initial Setup:** Register your admin account
2. **Create Structure:** Set up workspaces and applications
3. **Design Schema:** Create tables for your use case
4. **Generate API Token:** For programmatic access
5. **Test Integration:** Connect with n8n or Python
6. **Build Workflows:** Automate data collection and processing
7. **Create Views:** Visualize your data effectively
8. **Share Forms:** Collect data from users
9. **Monitor:** Track usage and performance
10. **Optimize:** Refine based on usage patterns

---

## Practical Example: Complete AI Pipeline

**Goal:** Build an AI customer support system with full data tracking

### Architecture:

```
User Question (Web/API)
    ↓
n8n Webhook Receives Request
    ↓
Check Baserow FAQ Table
    ↓
Found? → Return stored answer
    ↓
Not found? → Ollama generates answer
    ↓
Store in Baserow:
  - Question
  - Answer
  - Timestamp
  - User info
    ↓
Langfuse: Track LLM performance
    ↓
Return Answer to User
    ↓
Background Task:
  - Analyze sentiment
  - Update FAQ if helpful
  - Generate daily reports
```

### Implementation Steps:

**1. Baserow Setup:**
```
Application: "Customer Support"

Table 1: "FAQ"
- Question (Text)
- Answer (Long Text)
- Category (Single Select)
- Times Used (Number)
- Last Used (Date)

Table 2: "Conversations"
- User Email (Email)
- Question (Long Text)
- Answer (Long Text)
- Sentiment (Single Select)
- Was Helpful (Boolean)
- Timestamp (Date)
- Model Used (Single Select)

Table 3: "Daily Stats"
- Date (Date)
- Total Questions (Number)
- FAQ Hits (Number)
- AI Generated (Number)
- Avg Sentiment Score (Number)
- Top Question (Text)
```

**2. n8n Workflow Implementation:**

Available in your installation:
- Check `/n8n/backup/workflows/` for pre-built examples
- Adapt "AI Data Extraction with Baserow" workflow

**3. Monitor in Langfuse:**
- Track Ollama performance
- Identify slow queries
- Optimize prompts

**4. Analyze in Baserow:**
- Use views to see trends
- Export for deeper analysis
- Share dashboards with team

---

**Last Updated:** 2025-10-07

For issues specific to the AI LaunchKit Local setup:
- [Report Issues](https://github.com/hermannheinrich/ai-launchkit-local/issues)
- [Configuration Details](BASEROW_FIX.md)
- [Main Documentation](../README.md)
