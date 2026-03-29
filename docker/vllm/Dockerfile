# vLLM with transformers from main branch for GLM-4.7-Flash support
# Based on official vllm-openai image
#
# IMPORTANT: CUDA/Driver Compatibility
# - Driver 580.x requires CUDA 13.0 runtime (Error 803 with older runtimes)
# - cu130-nightly has the actual CUDA 13.0 runtime → works with driver 580
# - v0.15.1-cu130 only has cu130 PyTorch WHEELS but an older CUDA runtime
#   → still gets Error 803 with driver 580
#
# AWQ FIX for nightly (0.16.x):
# - vLLM 0.16.x introduced DeepSeekV2FusedQkvAProj for fused_qkv_a_proj
# - AWQ quant configs only have targets for q_a_proj/kv_a_proj (not fused)
# - Fix: patch get_quant_method() to catch ValueError for unmatched layers
#   and return None (layer runs unquantized in BF16 — small accuracy impact)

FROM vllm/vllm-openai:cu130-nightly

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

# Patch compressed-tensors to fix UnboundLocalError for UnquantizedLinearMethod.
# vLLM nightly has a Python scoping bug — the import is added at module level.
COPY patch_awq.py /tmp/patch_awq.py
RUN python3 /tmp/patch_awq.py && rm /tmp/patch_awq.py

# Set default environment variables
ENV HF_HOME=/root/.cache/huggingface

# Entrypoint wrapper: injects --override-generation-config '{"enable_thinking": false}'
# before all other args. Single quotes in the shell script work correctly —
# avoids docker-compose command string quoting issues entirely.
COPY entrypoint.sh /opt/vllm-entrypoint.sh
RUN chmod +x /opt/vllm-entrypoint.sh

EXPOSE 8000
ENTRYPOINT ["/opt/vllm-entrypoint.sh"]
