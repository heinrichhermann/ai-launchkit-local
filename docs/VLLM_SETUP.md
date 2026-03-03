# vLLM Setup Guide

vLLM is a high-performance LLM inference and serving engine that provides an **OpenAI-compatible API**. It's designed for production deployments with state-of-the-art throughput using PagedAttention.

## Overview

| Feature | Details |
|---------|---------|
| **Port** | 8032 |
| **Profile** | `vllm` |
| **GPU Required** | Yes (NVIDIA CUDA) |
| **API Compatibility** | OpenAI API v1 |
| **Documentation** | [vLLM Docs](https://docs.vllm.ai) |

## Quick Start

### 1. Prerequisites

- **NVIDIA GPU** with CUDA support (minimum 8GB VRAM recommended)
- **NVIDIA Container Toolkit** installed
- **HuggingFace Token** (for gated models like Llama)

### 2. Get HuggingFace Token

1. Create an account at [huggingface.co](https://huggingface.co)
2. Go to [Settings → Access Tokens](https://huggingface.co/settings/tokens)
3. Create a new token with "Read" permissions
4. Accept the model license (e.g., [Llama 3.1](https://huggingface.co/meta-llama/Llama-3.1-8B-Instruct))

### 3. Configure Environment

Add to your `.env` file:

```bash
# Required for gated models
HF_TOKEN=hf_your_token_here

# Model selection (default: Llama 3.1 8B)
VLLM_MODEL=meta-llama/Llama-3.1-8B-Instruct

# GPU memory utilization (0.0-1.0)
VLLM_GPU_MEMORY_UTILIZATION=0.9

# Maximum context length
VLLM_MAX_MODEL_LEN=8192
```

### 4. Start vLLM

```bash
# Add vllm to your profiles
COMPOSE_PROFILES="n8n,vllm,gpu-nvidia" docker compose up -d
```

## Configuration Options

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HF_TOKEN` | - | HuggingFace token for gated models |
| `VLLM_MODEL` | `meta-llama/Llama-3.1-8B-Instruct` | HuggingFace model ID |
| `VLLM_GPU_MEMORY_UTILIZATION` | `0.9` | GPU memory fraction (0.0-1.0) |
| `VLLM_MAX_MODEL_LEN` | `8192` | Maximum context length |
| `VLLM_TENSOR_PARALLEL_SIZE` | `1` | Number of GPUs for tensor parallelism |
| `VLLM_DTYPE` | `auto` | Data type (auto, float16, bfloat16) |
| `VLLM_API_KEY` | - | Optional API key for authentication |
| `VLLM_EXTRA_ARGS` | - | Additional vLLM server arguments |

### Recommended Models

| Model | VRAM Required | Description |
|-------|---------------|-------------|
| `meta-llama/Llama-3.1-8B-Instruct` | ~16GB | Best balance of quality and speed |
| `mistralai/Mistral-7B-Instruct-v0.3` | ~14GB | Fast, good for general tasks |
| `Qwen/Qwen2.5-7B-Instruct` | ~14GB | Excellent multilingual support |
| `meta-llama/Llama-3.1-70B-Instruct` | ~140GB | Best quality, requires multi-GPU |

### Quantized Models (Lower VRAM)

For GPUs with limited VRAM, use quantized models:

```bash
# AWQ quantized (4-bit)
VLLM_MODEL=TheBloke/Llama-2-7B-Chat-AWQ
VLLM_EXTRA_ARGS=--quantization awq
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
