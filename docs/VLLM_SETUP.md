# vLLM Setup Guide

vLLM is a high-performance LLM inference and serving engine that provides an **OpenAI-compatible API**. It's designed for production deployments with state-of-the-art throughput using PagedAttention.

## Overview

| Feature | Details |
|---------|---------|
| **Port** | 8032 |
| **Profile** | `vllm` |
| **GPU Required** | Yes (NVIDIA CUDA) |
| **Default Model** | QuantTrio/GLM-4.7-Flash-AWQ (19GB AWQ quantized) |
| **API Compatibility** | OpenAI API v1 |
| **Documentation** | [vLLM Docs](https://docs.vllm.ai) |

## Quick Start

### 1. Prerequisites

- **NVIDIA GPU** with CUDA support
  - Single GPU: 24GB+ VRAM (RTX 3090, RTX 4090, A100)
  - Dual GPU: 2x 24GB (recommended for GLM-4.7-Flash-AWQ)
- **NVIDIA Container Toolkit** installed
- **HuggingFace Token** (optional, only for gated models like Llama)

### 2. Default Configuration (GLM-4.7-Flash-AWQ)

The default configuration is optimized for **2x RTX 3090** (48GB total VRAM):

```bash
# Default model: QuantTrio/GLM-4.7-Flash-AWQ (19GB, no HF token required!)
VLLM_MODEL=QuantTrio/GLM-4.7-Flash-AWQ

# Tensor parallelism for 2 GPUs
VLLM_TENSOR_PARALLEL_SIZE=2

# GPU memory utilization
VLLM_GPU_MEMORY_UTILIZATION=0.9

# Context length (32K tokens)
VLLM_MAX_MODEL_LEN=32768

# Data type (bfloat16 for best quality)
VLLM_DTYPE=bfloat16

# Swap space for KV cache overflow
VLLM_SWAP_SPACE=4

# Extra args for MoE optimization and tool calling
VLLM_EXTRA_ARGS=--enable-expert-parallel --enable-auto-tool-choice --tool-call-parser glm47 --reasoning-parser glm45 --speculative-config.method mtp --speculative-config.num_speculative_tokens 1 --trust-remote-code
```

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
| `QuantTrio/GLM-4.7-Flash-AWQ` | ~19GB | 2x 24GB | **Default** - AWQ quantized, fits 2x RTX 3090 |
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

### Quantized Models (Recommended for 2x RTX 3090)

The default AWQ quantized version is optimized for 2x RTX 3090:

```bash
# AWQ quantized GLM-4.7-Flash (19GB) - fits on 2x 24GB GPUs
VLLM_MODEL=QuantTrio/GLM-4.7-Flash-AWQ
VLLM_TENSOR_PARALLEL_SIZE=2
VLLM_SWAP_SPACE=4
VLLM_EXTRA_ARGS=--enable-expert-parallel --enable-auto-tool-choice --tool-call-parser glm47 --reasoning-parser glm45 --speculative-config.method mtp --speculative-config.num_speculative_tokens 1 --trust-remote-code
```

### Environment Variables for GLM-4.7-Flash-AWQ

The docker-compose.local.yml automatically sets these optimization flags:

```bash
# Required for optimal MoE performance with FlashInfer
VLLM_USE_DEEP_GEMM=0
VLLM_USE_FLASHINFER_MOE_FP16=1
VLLM_USE_FLASHINFER_SAMPLER=0
OMP_NUM_THREADS=4
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
