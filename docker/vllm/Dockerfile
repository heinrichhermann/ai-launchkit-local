# vLLM with latest transformers for Gemma 4 / Qwen3.5 support
# Based on official vllm-openai stable image (latest-cu130 = latest stable)
#
# IMPORTANT: CUDA/Driver Compatibility
# - Driver 580.x requires CUDA 13.0 runtime (Error 803 with older runtimes)
# - latest-cu130 = v0.19.0+ with CUDA 13.0 runtime → works with driver 580
#
# AWQ FIX: patch compressed-tensors for VisionTransformer layers in AWQ models
# - Catches ValueError for unmatched layers (e.g. vision layers not in AWQ config)
# - Layer runs unquantized in BF16 — minimal accuracy impact

FROM vllm/vllm-openai:latest-cu130

# Set library paths for CUDA/cuDNN
ENV LD_LIBRARY_PATH=/usr/lib64:/usr/local/nvidia/lib64:/usr/local/cuda/lib64:/usr/local/nvidia/lib
ENV CUDA_VERSION=130
ENV UV_TORCH_BACKEND=cu130

# Install transformers>=5.5.0 (required for Gemma 4 support per vLLM v0.19.0 release notes)
# - Gemma 4 requires transformers>=5.5.0
# - Force reinstall numba to fix compatibility issues
# - Use uv for faster installation (already in vllm image)
RUN uv pip install --system "transformers>=5.5.0" && \
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
COPY qwen3.5_chat_template.jinja /opt/qwen3.5_chat_template.jinja
COPY entrypoint.sh /opt/vllm-entrypoint.sh
RUN chmod +x /opt/vllm-entrypoint.sh

EXPOSE 8000
ENTRYPOINT ["/opt/vllm-entrypoint.sh"]
