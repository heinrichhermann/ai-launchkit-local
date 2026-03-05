# vLLM Setup Guide

vLLM is a high-performance LLM inference and serving engine that provides an **OpenAI-compatible API**. It's designed for production deployments with state-of-the-art throughput using PagedAttention.

## Overview

| Feature | Details |
|---------|---------|
| **Port** | 8032 |
| **Profile** | `vllm` |
| **GPU Required** | Yes (NVIDIA CUDA) |
| **Default Model** | unsloth/GLM-4.7-Flash-FP8-Dynamic (official Unsloth FP8) |
| **API Compatibility** | OpenAI API v1 |
| **Documentation** | [vLLM Docs](https://docs.vllm.ai) |
| **Reference** | [Unsloth GLM-4.7-Flash Guide](https://unsloth.ai/docs/de/modelle/glm-4.7-flash) |

## Quick Start

### 1. Prerequisites

- **NVIDIA GPU** with CUDA support
  - Single GPU: 24GB+ VRAM (RTX 3090, RTX 4090, A100)
  - Dual GPU: 2x 24GB (recommended for GLM-4.7-Flash-FP8-Dynamic)
  - Quad GPU: 4x 24GB (for full 200K context)
- **NVIDIA Container Toolkit** installed
- **HuggingFace Token** (optional, only for gated models like Llama)

### 2. Default Configuration (GLM-4.7-Flash-FP8-Dynamic)

The default configuration is optimized for **2x RTX 3090** (48GB total VRAM):

```bash
# Default model: unsloth/GLM-4.7-Flash-FP8-Dynamic (official Unsloth FP8)
VLLM_MODEL=unsloth/GLM-4.7-Flash-FP8-Dynamic

# Served model name (how it appears in API)
VLLM_SERVED_MODEL_NAME=unsloth/GLM-4.7-Flash

# Tensor parallelism for 2 GPUs
VLLM_TENSOR_PARALLEL_SIZE=2

# GPU memory utilization (95% per Unsloth docs)
VLLM_GPU_MEMORY_UTILIZATION=0.95

# Context length (32K tokens for 2x 3090, up to 200K for 4x GPUs)
VLLM_MAX_MODEL_LEN=32768

# Data type (bfloat16 for best quality)
VLLM_DTYPE=bfloat16
```

### Key Features (automatically configured):
- **FP8 KV-Cache**: `--kv-cache-dtype fp8` reduces memory by 50%
- **Tool Calling**: `--tool-call-parser glm47 --reasoning-parser glm45 --enable-auto-tool-choice`
- **Seed**: `--seed 3407` for reproducibility

### 3. Alternative: Gated Models (Llama)

For gated models like Llama, you need a HuggingFace token:

1. Create an account at [huggingface.co](https://huggingface.co)
2. Go to [Settings → Access Tokens](https://huggingface.co/settings/tokens)
3. Create a new token with "Read" permissions
4. Accept the model license (e.g., [Llama 3.1](https://huggingface.co/meta-llama/Llama-3.1-8B-Instruct))

```bash
HF_TOKEN=hf_your_token_here
VLLM_MODEL=meta-llama/Llama-3.1-8B-Instruct
VLLM_TENSOR_PARALLEL_SIZE=1
VLLM_MAX_MODEL_LEN=8192
```

### 4. Start vLLM

```bash
# Add vllm to your profiles
COMPOSE_PROFILES="vllm" docker compose up -d
```

> **Note**: AI LaunchKit verwendet ein Custom Dockerfile das automatisch die neueste transformers Version für GLM-4.7-Flash Support installiert. Der erste Build dauert ca. 5-10 Minuten.

## Configuration Options

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HF_TOKEN` | - | HuggingFace token for gated models |
| `VLLM_MODEL` | `zai-org/GLM-4.7-Flash` | HuggingFace model ID |
| `VLLM_GPU_MEMORY_UTILIZATION` | `0.9` | GPU memory fraction (0.0-1.0) |
| `VLLM_MAX_MODEL_LEN` | `32768` | Maximum context length |
| `VLLM_TENSOR_PARALLEL_SIZE` | `2` | Number of GPUs for tensor parallelism |
| `VLLM_DTYPE` | `bfloat16` | Data type (auto, float16, bfloat16) |
| `VLLM_API_KEY` | - | Optional API key for authentication |
| `VLLM_EXTRA_ARGS` | `--trust-remote-code` | Additional vLLM server arguments |

### Recommended Models

| Model | VRAM Required | GPUs | Description |
|-------|---------------|------|-------------|
| `unsloth/GLM-4.7-Flash-FP8-Dynamic` | ~30GB | 2x 24GB | **Default** - Official Unsloth FP8, best quality |
| `zai-org/GLM-4.7-Flash` | ~60GB | 4x 24GB | Original BF16, needs 4 GPUs |
| `meta-llama/Llama-3.1-8B-Instruct` | ~16GB | 1x 24GB | Good balance, requires HF token |
| `Qwen/Qwen2.5-7B-Instruct` | ~14GB | 1x 24GB | Excellent multilingual support |

### GLM-4.7-Flash Benchmarks

| Benchmark | GLM-4.7-Flash | Qwen3-30B-A3B | GPT-OSS-20B |
|-----------|---------------|---------------|-------------|
| AIME 25 (Math) | **91.6** | 85.0 | 91.7 |
| GPQA (Science) | **75.2** | 73.4 | 71.5 |
| SWE-bench (Coding) | **59.2** | 22.0 | 34.0 |
| τ²-Bench (Agentic) | **79.5** | 49.0 | 47.7 |

### FP8 Dynamic Quantization (Recommended)

The default FP8 Dynamic version from Unsloth is optimized for quality and speed:

```bash
# Official Unsloth FP8 Dynamic - best quality
VLLM_MODEL=unsloth/GLM-4.7-Flash-FP8-Dynamic
VLLM_TENSOR_PARALLEL_SIZE=2
VLLM_GPU_MEMORY_UTILIZATION=0.95
```

### Environment Variables for GLM-4.7-Flash

The docker-compose.local.yml automatically sets these optimization flags:

```bash
# Required for FP8 (from Unsloth docs)
PYTORCH_CUDA_ALLOC_CONF=expandable_segments:False
```

### Single GPU Configuration

For single GPU setups (1x RTX 3090/4090):

```bash
VLLM_MODEL=unsloth/GLM-4.7-Flash-FP8-Dynamic
VLLM_TENSOR_PARALLEL_SIZE=1
VLLM_MAX_MODEL_LEN=16384  # Reduce context for single GPU
VLLM_GPU_MEMORY_UTILIZATION=0.95
```

### Quad GPU Configuration (Full 200K Context)

For 4x GPU setups (4x RTX 3090/4090 or A100):

```bash
VLLM_MODEL=unsloth/GLM-4.7-Flash-FP8-Dynamic
VLLM_TENSOR_PARALLEL_SIZE=4
VLLM_MAX_MODEL_LEN=200000  # Full 200K context
VLLM_GPU_MEMORY_UTILIZATION=0.95
```

## OpenAI-Compatible API

vLLM provides a drop-in replacement for the OpenAI API.

### Endpoint

```
http://SERVER_IP:8032/v1
```

### Supported Endpoints

- `POST /v1/chat/completions` - Chat completions
- `POST /v1/completions` - Text completions
- `GET /v1/models` - List available models
- `GET /health` - Health check

### Example: Chat Completion

```bash
curl http://localhost:8032/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "meta-llama/Llama-3.1-8B-Instruct",
    "messages": [
      {"role": "user", "content": "Hello, how are you?"}
    ],
    "max_tokens": 100
  }'
```

### Example: Python Client

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:8032/v1",
    api_key="not-needed"  # or your VLLM_API_KEY if set
)

response = client.chat.completions.create(
    model="meta-llama/Llama-3.1-8B-Instruct",
    messages=[
        {"role": "user", "content": "Explain quantum computing in simple terms"}
    ]
)

print(response.choices[0].message.content)
```

## Integration with AI LaunchKit Services

### Open WebUI

Configure Open WebUI to use vLLM as an OpenAI-compatible backend:

1. Go to **Settings → Connections**
2. Add new OpenAI connection:
   - **URL**: `http://vllm:8000/v1`
   - **API Key**: Leave empty (or your `VLLM_API_KEY`)

### n8n

Use the **OpenAI** node with custom base URL:

1. Create new OpenAI credentials
2. Set **Base URL**: `http://vllm:8000/v1`
3. Set **API Key**: Any value (or your `VLLM_API_KEY`)

### Flowise

Configure OpenAI Chat Model node:

1. Add **OpenAI Chat Model** node
2. Set **Base Path**: `http://vllm:8000/v1`
3. Set **Model Name**: Your model ID (e.g., `meta-llama/Llama-3.1-8B-Instruct`)

## Multi-GPU Setup

For large models or higher throughput, use tensor parallelism:

```bash
# 2 GPUs
VLLM_TENSOR_PARALLEL_SIZE=2

# 4 GPUs
VLLM_TENSOR_PARALLEL_SIZE=4
```

**Note**: The model must be evenly divisible across GPUs.

## Performance Tuning

### Maximize Throughput

```bash
# Use more GPU memory
VLLM_GPU_MEMORY_UTILIZATION=0.95

# Enable continuous batching (default)
VLLM_EXTRA_ARGS=--enable-chunked-prefill
```

### Reduce Latency

```bash
# Smaller batch sizes
VLLM_EXTRA_ARGS=--max-num-seqs 8

# Disable speculative decoding
VLLM_EXTRA_ARGS=--disable-log-stats
```

### Memory Optimization

```bash
# Reduce context length
VLLM_MAX_MODEL_LEN=4096

# Use quantization
VLLM_EXTRA_ARGS=--quantization awq
```

## Troubleshooting

### Out of Memory (OOM)

```bash
# Reduce GPU memory utilization
VLLM_GPU_MEMORY_UTILIZATION=0.8

# Reduce context length
VLLM_MAX_MODEL_LEN=4096

# Use quantized model
VLLM_MODEL=TheBloke/Llama-2-7B-Chat-AWQ
VLLM_EXTRA_ARGS=--quantization awq
```

### Model Not Found

1. Check HuggingFace token is set: `HF_TOKEN=hf_xxx`
2. Accept model license on HuggingFace website
3. Verify model ID is correct

### Slow Startup

First startup downloads the model (~15GB for 8B models). Subsequent starts use cached model.

```bash
# Check download progress
docker logs -f vllm
```

### Connection Refused

```bash
# Check if vLLM is running
docker ps | grep vllm

# Check logs for errors
docker logs vllm

# Verify health endpoint
curl http://localhost:8032/health
```

## Comparison: vLLM vs Ollama

| Feature | vLLM | Ollama |
|---------|------|--------|
| **Performance** | Higher throughput | Good for single user |
| **API** | OpenAI-compatible | Custom + OpenAI-compatible |
| **Models** | HuggingFace models | Ollama model library |
| **Quantization** | AWQ, GPTQ, FP8 | GGUF (llama.cpp) |
| **Multi-GPU** | Native support | Limited |
| **Use Case** | Production serving | Development/testing |

**Recommendation**: Use vLLM for production workloads with high throughput requirements. Use Ollama for development and testing.

## Resources

- [vLLM Documentation](https://docs.vllm.ai)
- [vLLM GitHub](https://github.com/vllm-project/vllm)
- [Supported Models](https://docs.vllm.ai/en/latest/models/supported_models.html)
- [OpenAI API Reference](https://platform.openai.com/docs/api-reference)
