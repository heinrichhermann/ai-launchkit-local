# Qdrant Vector Database - Setup Guide

> **TL;DR:** Qdrant is a high-performance vector database for AI applications. This guide shows you how to configure the API key and connect from n8n or other services.

## 🎯 What is Qdrant?

Qdrant is a vector similarity search engine that enables:
- Semantic search across documents
- RAG (Retrieval Augmented Generation) systems
- Recommendation engines
- Content deduplication

## 🔐 API Key Configuration

### Step 1: Find Your API Key

The API key is automatically generated during installation and stored in `.env`:

```bash
# On your Ubuntu server:
cd ~/ai-launchkit-local
grep "QDRANT_API_KEY" .env
```

**Example output:**
```
QDRANT_API_KEY=your-generated-api-key-here-32-characters
```

**Copy this key** - you'll need it for the Qdrant UI and API calls.

### Step 2: Access Qdrant Dashboard

1. **Open browser:** `http://SERVER_IP:8026/dashboard`
2. **First visit:** You'll see the authentication screen
3. **Enter API Key:** Paste your `QDRANT_API_KEY` from `.env`
4. **Login:** You're now in the Qdrant dashboard!

### Step 3: Create Your First Collection

**In Qdrant Dashboard:**

1. Click **"Collections"** in left menu
2. Click **"+ Create Collection"**
3. **Configure:**
   ```
   Collection Name: documents
   Vector Size: 768 (for nomic-embed-text)
   Distance: Cosine
   ```
4. **Create**

**Your collection is ready for use!**

## 🔌 Using Qdrant from n8n

### Connect Qdrant to n8n Workflow

1. **Open n8n:** `http://SERVER_IP:8000`
2. **Add Qdrant Node** to your workflow
3. **Configure Connection:**
   ```
   URL: http://qdrant:6333
   API Key: [Your QDRANT_API_KEY from .env]
   ```
4. **Select Collection:** documents (or your collection name)

### Example: Store Documents in Qdrant

**Use the "Qdrant Vector Store" node in n8n:**

```json
{
  "operation": "insert",
  "collection": "documents",
  "documents": [
    {
      "text": "Your document content here",
      "metadata": {
        "source": "example.pdf",
        "page": 1
      }
    }
  ]
}
```

### Example: Search Similar Documents

```json
{
  "operation": "retrieve",
  "collection": "documents",
  "query": "What is AI?",
  "limit": 5
}
```

## 📡 Direct API Usage

### Get API Info

```bash
curl http://SERVER_IP:8026
```

### List Collections

```bash
curl -X GET http://SERVER_IP:8026/collections \
  -H "api-key: YOUR_QDRANT_API_KEY"
```

### Search Vectors

```bash
curl -X POST http://SERVER_IP:8026/collections/documents/points/search \
  -H "api-key: YOUR_QDRANT_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "vector": [0.1, 0.2, 0.3, ...],
    "limit": 5,
    "with_payload": true
  }'
```

## 🤝 Integration with Ollama Embeddings

**Typical RAG Workflow in n8n:**

```
1. Document Input
   ↓
2. Embedding (Ollama nomic-embed-text)
   ↓
3. Store in Qdrant (insert operation)
   ↓
4. Query Time:
   - User Question
   ↓
5. Embedding (same model!)
   ↓
6. Qdrant Search (retrieve operation)
   ↓
7. Send to LLM with context
```

## 🔧 Troubleshooting

### Can't Access Dashboard

**Check if Qdrant is running:**
```bash
docker ps | grep qdrant
docker logs qdrant
```

**Test API endpoint:**
```bash
curl http://localhost:8026
```

### API Key Not Working

**Verify API key in .env:**
```bash
cat .env | grep QDRANT_API_KEY
```

**Restart Qdrant:**
```bash
docker compose -p localai -f docker-compose.local.yml restart qdrant
```

### Connection Refused from n8n

**Check network:**
```bash
docker exec n8n ping qdrant
```

**Should resolve to Qdrant container IP.**

## 📚 Official Documentation

- **Qdrant Official Docs:** https://qdrant.tech/documentation/
- **API Reference:** https://qdrant.tech/documentation/interfaces/
- **n8n Integration:** https://docs.n8n.io/integrations/builtin/cluster-nodes/root-nodes/n8n-nodes-langchain.vectorstoreqdrant/

## 💡 Best Practices

1. **API Key Security:** Never commit API keys to Git
2. **Collection Names:** Use descriptive names (e.g., `product_docs`, `customer_support`)
3. **Vector Dimensions:** Match your embedding model (nomic-embed-text = 768)
4. **Distance Metric:** Use Cosine for semantic similarity
5. **Indexing:** Qdrant handles indexing automatically for fast search

---

**Need more help?** Check the official Qdrant documentation or ask in the AI LaunchKit community!
