# vLLM Setup Guide

vLLM is a high-performance LLM inference and serving engine that provides an **OpenAI-compatible API**. It's designed for production deployments with state-of-the-art throughput using PagedAttention.

## Overview

| Feature | Details |
|---------|---------|
| **Port** | 8032 |
| **Profile** | `vllm` |
| **GPU Required** | Yes (NVIDIA CUDA) |
| **Default Model** | Qwen/Qwen2.5-7B-Instruct (works on all GPUs) |
| **API Compatibility** | OpenAI API v1 |
| **Documentation** | [vLLM Docs](https://docs.vllm.ai) |

## GPU Compatibility

> ⚠️ **IMPORTANT**: Model selection depends on your GPU architecture and vLLM version!

| GPU Architecture | Examples | Recommended Models |
|------------------|----------|-------------------|
| **Ampere 1x** | RTX 3090, A100 | Qwen2.5-7B-Instruct, GLM-4.7-Flash-AWQ-4bit |
| **Ampere 2x/3x** | 2-3x RTX 3090 | GLM-4.7-Flash-AWQ-4bit (TP=2), Qwen2.5-14B |
| **Ampere 4x+** | 4x RTX 3090 | zai-org/GLM-4.7-Flash BF16 (TP=4) |
| **Ada Lovelace** | RTX 4090 | Qwen2.5-7B-Instruct, GLM-4.7-Flash-AWQ-4bit |
| **Hopper** | H100 | zai-org/GLM-4.7-Flash BF16 (TP=4+) |

### GLM-4.7-Flash on RTX 3090 (AWQ 4-bit)

Use `cyankiwi/GLM-4.7-Flash-AWQ-4bit` — the **AWQ 4-bit quantized** version fits on a single RTX 3090 (17.2GB):

```bash
VLLM_MODEL=cyankiwi/GLM-4.7-Flash-AWQ-4bit
VLLM_SERVED_MODEL_NAME=GLM-4.7-Flash
VLLM_TENSOR_PARALLEL_SIZE=2          # TP=2 for 2x/3x RTX 3090 (20 heads → TP must be 1,2,4,5...)
VLLM_GPU_MEMORY_UTILIZATION=0.90
VLLM_DTYPE=bfloat16
VLLM_EXTRA_ARGS=--tool-call-parser glm47 --reasoning-parser glm45 --enable-auto-tool-choice
```

> **Note on TP**: GLM-4.7-Flash has `num_attention_heads=20`. TP must divide 20 evenly.
> **TP=3 does NOT work** on 3x RTX 3090. Use TP=2 (2 GPUs, 3rd GPU free for other tasks).

### vLLM Version Requirement

The Dockerfile uses `v0.15.1-cu130` (stable). **Do not use the nightly/0.16.x builds** — they have a bug where `DeepSeekV2FusedQkvAProj` (the new fused QKV layer) breaks compressed-tensors AWQ quantization matching:

```
ValueError: Unable to find matching target for model.layers.X.self_attn.fused_qkv_a_proj
```

vLLM 0.15.1 uses `MergedColumnParallelLinear` for the same layer, which works correctly with AWQ.

## Quick Start

### 1. Prerequisites

- **NVIDIA GPU** with CUDA support
  - Single GPU: 24GB+ VRAM (RTX 3090, RTX 4090, A100)
  - Multi-GPU: For larger models
- **NVIDIA Container Toolkit** installed
- **HuggingFace Token** (optional, only for gated models like Llama)

### 2. Default Configuration (Qwen2.5-7B-Instruct)

The default configuration works on **any NVIDIA GPU with 24GB+ VRAM**:

```bash
# Default model: Qwen2.5-7B-Instruct (works on all GPUs)
VLLM_MODEL=Qwen/Qwen2.5-7B-Instruct

# Served model name (how it appears in API)
VLLM_SERVED_MODEL_NAME=Qwen2.5-7B-Instruct

# Single GPU is sufficient
VLLM_TENSOR_PARALLEL_SIZE=1

# GPU memory utilization
VLLM_GPU_MEMORY_UTILIZATION=0.9

# Context length (32K tokens)
VLLM_MAX_MODEL_LEN=32768

# Data type (auto for best compatibility)
VLLM_DTYPE=auto
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

> **Note**: AI LaunchKit uses a custom Dockerfile that installs the latest transformers version. First build takes ~5-10 minutes.

## Configuration Options

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HF_TOKEN` | - | HuggingFace token for gated models |
| `VLLM_MODEL` | `Qwen/Qwen2.5-7B-Instruct` | HuggingFace model ID |
| `VLLM_GPU_MEMORY_UTILIZATION` | `0.9` | GPU memory fraction (0.0-1.0) |
| `VLLM_MAX_MODEL_LEN` | `32768` | Maximum context length |
| `VLLM_TENSOR_PARALLEL_SIZE` | `1` | Number of GPUs for tensor parallelism |
| `VLLM_DTYPE` | `auto` | Data type (auto, float16, bfloat16) |
| `VLLM_API_KEY` | - | Optional API key for authentication |
| `VLLM_EXTRA_ARGS` | - | Additional vLLM server arguments |

### Recommended Models by GPU Setup

| Model | VRAM Required | GPUs | Best For |
|-------|---------------|------|----------|
| `Qwen/Qwen2.5-7B-Instruct` | ~14GB | 1x 24GB | **Default** - Works on all GPUs |
| `meta-llama/Llama-3.1-8B-Instruct` | ~16GB | 1x 24GB | Good balance, requires HF token |
| `Qwen/Qwen2.5-14B-Instruct` | ~28GB | 2x 24GB | Better quality, needs 2 GPUs |
| `cyankiwi/GLM-4.7-Flash-REAP-23B-A3B-AWQ-4bit` | ~24GB | 2x 24GB | **GLM-4.7 on 2x RTX 3090** |
| `unsloth/GLM-4.7-Flash-FP8-Dynamic` | ~30GB | 4x 24GB | FP8 quantized, best for 4 GPUs |
| `zai-org/GLM-4.7-Flash` | ~60GB | 4x 24GB | Original BF16, Hopper GPUs only |

### GLM-4.7-Flash Configuration

GLM-4.7-Flash is a powerful 30B MoE reasoning model with excellent benchmarks. However, it has specific hardware requirements:

#### Option 1: AWQ 4-bit Quantized (Works on 2x RTX 3090!) ✅

Use the [AWQ 4-bit quantized version](https://huggingface.co/cyankiwi/GLM-4.7-Flash-REAP-23B-A3B-AWQ-4bit) with FlashInfer backend:

```bash
# AWQ 4-bit version - works on 2x RTX 3090!
VLLM_MODEL=cyankiwi/GLM-4.7-Flash-REAP-23B-A3B-AWQ-4bit
VLLM_SERVED_MODEL_NAME=GLM-4.7-Flash
VLLM_TENSOR_PARALLEL_SIZE=2
VLLM_MAX_MODEL_LEN=32768
VLLM_GPU_MEMORY_UTILIZATION=0.85
VLLM_DTYPE=bfloat16

# FlashInfer backend for MoE optimization (required for Ampere GPUs)
VLLM_USE_FLASHINFER_MOE=1
VLLM_FLASHINFER_MOE_BACKEND=throughput
VLLM_ATTENTION_BACKEND=FLASHINFER
VLLM_USE_FLASHINFER_SAMPLER=1

# GLM-4.7 specific arguments
VLLM_EXTRA_ARGS=--tool-call-parser glm47 --reasoning-parser glm45 --enable-auto-tool-choice --enable-expert-parallel --max-num-batched-tokens 8192
```

**Key optimizations for RTX 3090:**
- `--enable-expert-parallel`: Distributes MoE experts across GPUs
- `--max-num-batched-tokens 8192`: Limits batch size to prevent OOM
- `VLLM_ATTENTION_BACKEND=FLASHINFER`: Uses FlashInfer for better MoE performance
- `VLLM_GPU_MEMORY_UTILIZATION=0.85`: Leaves headroom for KV cache

#### Option 2: FP8 Quantized (Recommended for 4x 24GB GPUs)

Use the [Unsloth FP8 Dynamic](https://huggingface.co/unsloth/GLM-4.7-Flash-FP8-Dynamic) version which reduces memory by ~50%:

```bash
# FP8 quantized version - requires 4x 24GB GPUs
VLLM_MODEL=unsloth/GLM-4.7-Flash-FP8-Dynamic
VLLM_TENSOR_PARALLEL_SIZE=4
VLLM_MAX_MODEL_LEN=32768
VLLM_GPU_MEMORY_UTILIZATION=0.95
VLLM_EXTRA_ARGS=--quantization fp8 --kv-cache-dtype fp8 --tool-call-parser glm47 --reasoning-parser glm45 --enable-auto-tool-choice
```

#### Option 3: Original BF16 (Hopper GPUs Only)

> ⚠️ **Only for H100 or similar Hopper GPUs!**

The original model uses MLA (Multi-head Latent Attention) which is optimized for Hopper architecture:

```bash
# Original BF16 - requires H100 or 4x 24GB Hopper GPUs
VLLM_MODEL=zai-org/GLM-4.7-Flash
VLLM_TENSOR_PARALLEL_SIZE=4
VLLM_MAX_MODEL_LEN=32768
VLLM_GPU_MEMORY_UTILIZATION=0.9
VLLM_EXTRA_ARGS=--tool-call-parser glm47 --reasoning-parser glm45 --enable-auto-tool-choice
```

#### Why Original GLM-4.7-Flash Fails on 2x RTX 3090

1. **Memory**: The original model requires ~60GB VRAM (BF16)
2. **MoE Architecture**: Each expert layer needs to be loaded, causing OOM during initialization
3. **MLA Attention**: Optimized for Hopper GPUs, has performance issues on Ampere

**Solution**: Use the AWQ 4-bit quantized version with FlashInfer backend (Option 1).

### Single GPU Configuration (RTX 3090/4090)

```bash
VLLM_MODEL=Qwen/Qwen2.5-7B-Instruct
VLLM_TENSOR_PARALLEL_SIZE=1
VLLM_MAX_MODEL_LEN=32768
VLLM_GPU_MEMORY_UTILIZATION=0.9
```

### Dual GPU Configuration (2x RTX 3090)

#### Standard Models

```bash
# Use a larger model with 2 GPUs
VLLM_MODEL=Qwen/Qwen2.5-14B-Instruct
VLLM_TENSOR_PARALLEL_SIZE=2
VLLM_MAX_MODEL_LEN=32768
VLLM_GPU_MEMORY_UTILIZATION=0.9
```

#### GLM-4.7-Flash AWQ (Recommended for Reasoning Tasks)

```bash
# GLM-4.7-Flash AWQ 4-bit for 2x RTX 3090
VLLM_MODEL=cyankiwi/GLM-4.7-Flash-REAP-23B-A3B-AWQ-4bit
VLLM_SERVED_MODEL_NAME=GLM-4.7-Flash
VLLM_TENSOR_PARALLEL_SIZE=2
VLLM_MAX_MODEL_LEN=32768
VLLM_GPU_MEMORY_UTILIZATION=0.85
VLLM_DTYPE=bfloat16
VLLM_USE_FLASHINFER_MOE=1
VLLM_ATTENTION_BACKEND=FLASHINFER
VLLM_USE_FLASHINFER_SAMPLER=1
VLLM_EXTRA_ARGS=--tool-call-parser glm47 --reasoning-parser glm45 --enable-auto-tool-choice --enable-expert-parallel --max-num-batched-tokens 8192
```

### Quad GPU Configuration (4x RTX 3090/4090)

```bash
# GLM-4.7-Flash FP8 for 4 GPUs
VLLM_MODEL=unsloth/GLM-4.7-Flash-FP8-Dynamic
VLLM_TENSOR_PARALLEL_SIZE=4
VLLM_MAX_MODEL_LEN=32768
VLLM_GPU_MEMORY_UTILIZATION=0.95
VLLM_EXTRA_ARGS=--quantization fp8 --kv-cache-dtype fp8 --tool-call-parser glm47 --reasoning-parser glm45 --enable-auto-tool-choice
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
