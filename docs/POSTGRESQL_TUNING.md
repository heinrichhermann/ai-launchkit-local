# PostgreSQL Performance Tuning for AI LaunchKit

## 🎯 Overview

AI LaunchKit uses a shared PostgreSQL instance for multiple services (n8n, Penpot, Baserow, etc.). This guide helps you optimize PostgreSQL for your hardware.

---

## 🖥️ Hardware Profiles

### Minimal (8GB RAM, 4 CPU Cores)
**For:** Testing, personal use, 1-5 services

```bash
# In .env
POSTGRES_MAX_CONNECTIONS=100
POSTGRES_SHARED_BUFFERS=256MB
POSTGRES_EFFECTIVE_CACHE_SIZE=2GB
POSTGRES_WORK_MEM=64MB
POSTGRES_MAX_WORKER_PROCESSES=2
```

**Supports:** ~5 services with 20 connections each

### Standard (16GB RAM, 8 CPU Cores) ⭐ Recommended
**For:** Production use, 5-10 services

```bash
# In .env
POSTGRES_MAX_CONNECTIONS=200
POSTGRES_SHARED_BUFFERS=1GB
POSTGRES_EFFECTIVE_CACHE_SIZE=8GB
POSTGRES_WORK_MEM=128MB
POSTGRES_MAX_WORKER_PROCESSES=4
```

**Supports:** ~10 services with 20 connections each

### High-End (96GB RAM, 16 CPU Cores)
**For:** Heavy workloads, 10+ services, large teams

```bash
# In .env
POSTGRES_MAX_CONNECTIONS=500
POSTGRES_SHARED_BUFFERS=24GB
POSTGRES_EFFECTIVE_CACHE_SIZE=72GB
POSTGRES_WORK_MEM=256MB
POSTGRES_MAX_WORKER_PROCESSES=16
```

**Supports:** ~25 services with 20 connections each

---

## 📊 Connection Allocation

### Current Services Using PostgreSQL

| Service | Default Pool Size | Notes |
|---------|------------------|-------|
| n8n (main) | 10 | Main application |
| n8n-worker (×N) | 10 each | N = N8N_WORKER_COUNT |
| Penpot | 60 | Design platform |
| Baserow | 30 | No-code database |
| NocoDB | 20 | Spreadsheet UI |
| Cal.com | 20 | Scheduling |
| Vikunja | 20 | Task management |
| Postiz | 20 | Social media |
| Langfuse | 30 | AI observability |
| Formbricks | 20 | Surveys |
| Metabase | 30 | Business intelligence |

**Total (worst case):** ~280 connections

**With 200 max_connections:** ✅ Safe
**With 100 max_connections:** ❌ Will fail under load

---

## 🔧 Calculation Formulas

### Memory Settings

**shared_buffers:**
```
Minimum: 256MB
Standard: 25% of RAM (e.g., 4GB for 16GB RAM)
Maximum: 8GB (diminishing returns above)

Formula: MIN(RAM * 0.25, 8GB)
```

**effective_cache_size:**
```
Should be ~75% of total RAM

Formula: RAM * 0.75
```

**work_mem:**
```
Per connection working memory

Formula: (RAM * 0.25) / max_connections
Minimum: 64MB
Maximum: 512MB
```

### Connection Limits

**max_connections:**
```
Formula: (Total Services × 20) + 50% buffer

Example:
- 10 services × 20 = 200 connections
- 50% buffer = 100
- Total = 300 connections
```

---

## 🚨 Troubleshooting

### Error: "sorry, too many clients already"

**Symptom:**
```
error: sorry, too many clients already
at pg-pool/index.js:45:11
```

**Causes:**
1. **Too many services** using PostgreSQL
2. **max_connections too low** for your setup
3. **Connection leaks** (services not closing connections)

**Solutions:**

**Immediate (temporary fix):**
```bash
# Restart PostgreSQL to clear connections
docker restart postgres

# Wait for services to reconnect
sleep 10
```

**Permanent fix:**
1. Increase `POSTGRES_MAX_CONNECTIONS` in .env
2. Add values from hardware profile above
3. Restart stack:
   ```bash
   docker compose -p localai -f docker-compose.local.yml down
   docker compose -p localai -f docker-compose.local.yml up -d
   ```

### Error: Out of Memory

**Symptom:**
```
WARNING: out of memory
could not fork new process
```

**Cause:** `shared_buffers` too high for available RAM

**Solution:**
```bash
# Reduce shared_buffers
POSTGRES_SHARED_BUFFERS=512MB  # Instead of 1GB
```

### Performance Issues

**Symptom:** Queries are slow

**Check current settings:**
```bash
docker exec postgres psql -U postgres -c "
  SELECT name, setting, unit 
  FROM pg_settings 
  WHERE name IN (
    'max_connections',
    'shared_buffers', 
    'effective_cache_size',
    'work_mem'
  );"
```

**Optimize:**
1. Increase `effective_cache_size`
2. Adjust `work_mem` for complex queries
3. Enable `pg_stat_statements` for query analysis

---

## 📈 Monitoring

### Check Connection Usage

```bash
# Current connections
docker exec postgres psql -U postgres -c "
  SELECT count(*) as current_connections 
  FROM pg_stat_activity;"

# Connections by service
docker exec postgres psql -U postgres -c "
  SELECT datname, count(*) 
  FROM pg_stat_activity 
  GROUP BY datname 
  ORDER BY count DESC;"

# Max connections limit
docker exec postgres psql -U postgres -c "
  SHOW max_connections;"
```

### Watch Connections in Real-Time

```bash
watch -n 1 'docker exec postgres psql -U postgres -c "
  SELECT count(*) as connections, 
         max_val.setting::int as max 
  FROM pg_stat_activity, 
       (SELECT setting FROM pg_settings WHERE name='\''max_connections'\'') max_val 
  GROUP BY max_val.setting;"'
```

---

## 🎯 Recommended Configurations

### For Different Use Cases

**Personal Development (8GB RAM):**
```bash
POSTGRES_MAX_CONNECTIONS=100
POSTGRES_SHARED_BUFFERS=512MB
POSTGRES_EFFECTIVE_CACHE_SIZE=4GB
N8N_WORKER_COUNT=1
```

**Small Team (16GB RAM):**
```bash
POSTGRES_MAX_CONNECTIONS=200
POSTGRES_SHARED_BUFFERS=2GB
POSTGRES_EFFECTIVE_CACHE_SIZE=12GB
N8N_WORKER_COUNT=2
```

**Production (32GB RAM):**
```bash
POSTGRES_MAX_CONNECTIONS=300
POSTGRES_SHARED_BUFFERS=4GB
POSTGRES_EFFECTIVE_CACHE_SIZE=24GB
N8N_WORKER_COUNT=4
```

**Enterprise (96GB RAM, 16 Cores):**
```bash
POSTGRES_MAX_CONNECTIONS=500
POSTGRES_SHARED_BUFFERS=8GB
POSTGRES_EFFECTIVE_CACHE_SIZE=72GB
POSTGRES_WORK_MEM=256MB
POSTGRES_MAX_WORKER_PROCESSES=16
N8N_WORKER_COUNT=8
```

---

## 🔄 Applying Changes

### Step 1: Update .env

```bash
# On your server
cd ~/ai/ai-launchkit-local
nano .env
```

Add the values from your hardware profile.

### Step 2: Restart PostgreSQL

```bash
# Restart just PostgreSQL
docker restart postgres

# Or restart entire stack for all services to pick up changes
docker compose -p localai -f docker-compose.local.yml down
docker compose -p localai -f docker-compose.local.yml up -d
```

### Step 3: Verify

```bash
# Check if new settings are active
docker exec postgres psql -U postgres -c "
  SELECT 
    name, 
    setting, 
    unit,
    source
  FROM pg_settings 
  WHERE name IN (
    'max_connections',
    'shared_buffers',
    'effective_cache_size',
    'work_mem',
    'max_worker_processes'
  );"
```

---

## 💡 Best Practices

### DO:
- ✅ Use recommended values for your RAM size
- ✅ Monitor connection usage regularly
- ✅ Increase gradually (test after each change)
- ✅ Keep 30-50% buffer in max_connections

### DON'T:
- ❌ Set shared_buffers > 25% of RAM
- ❌ Set max_connections too low (causes errors)
- ❌ Change settings without testing
- ❌ Restart during active workflows

---

## 🆘 Emergency Recovery

**If PostgreSQL won't start after config change:**

```bash
# Remove custom command temporarily
docker compose -p localai -f docker-compose.local.yml stop postgres

# Start with defaults
docker run --rm \
  -v langfuse_postgres_data:/var/lib/postgresql/data \
  postgres:17-alpine

# Fix .env values
# Then restart normally
```

---

## 📞 Support

### Get Help

- PostgreSQL logs: `docker logs postgres --tail 100`
- Connection issues: Check this guide
- Community: [AI LaunchKit Forum](https://thinktank.ottomator.ai/c/local-ai/18)

---

**Last Updated:** 8.11.2025
**Version:** 2.0
