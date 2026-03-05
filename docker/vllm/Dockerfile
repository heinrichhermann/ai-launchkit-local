# vLLM with transformers from main branch for GLM-4.7-Flash support
# Based on official vllm-openai image
#
# IMPORTANT: CUDA/Driver Compatibility
# - Driver 580.x supports CUDA 13.0
# - Using v0.15.1-cu130 stable tag (CUDA 13.0 compatible, no Error 803)
# - GLM-4.7-Flash (glm4_moe_lite) was merged into vLLM on 2026-01-19 (PR #31386)
#   and is included in v0.15.0+ stable releases
#
# WHY NOT cu130-nightly:
# - vLLM 0.16.x nightly replaced MergedColumnParallelLinear with
#   DeepSeekV2FusedQkvAProj for the fused_qkv_a_proj layer
# - This breaks compressed-tensors AWQ quant matching (ValueError: Unable to
#   find matching target for model.layers.X.self_attn.fused_qkv_a_proj)
# - v0.15.1 uses MergedColumnParallelLinear which works correctly with AWQ

FROM vllm/vllm-openai:v0.15.1-cu130

# Set library paths for CUDA/cuDNN
ENV LD_LIBRARY_PATH=/usr/lib64:/usr/local/nvidia/lib64:/usr/local/cuda/lib64:/usr/local/nvidia/lib
ENV CUDA_VERSION=130
ENV UV_TORCH_BACKEND=cu130

# Install transformers from main branch for GLM-4.7-Flash support
# - GLM-4.7-Flash (glm4_moe_lite) requires unreleased transformers
# - Force reinstall numba to fix compatibility issues
# - Use uv for faster installation (already in vllm image)
RUN uv pip install --system -U https://github.com/huggingface/transformers/archive/refs/heads/main.zip && \
    uv pip install --system --force-reinstall numba && \
    python3 -c "import transformers; print(f'Transformers {transformers.__version__} installed successfully')"

# Set default environment variables
ENV HF_HOME=/root/.cache/huggingface

EXPOSE 8000
ENTRYPOINT ["python3", "-m", "vllm.entrypoints.openai.api_server"]
