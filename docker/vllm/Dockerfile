# vLLM with transformers from main branch for GLM-4.7-Flash support
# Based on official vllm-openai image
#
# IMPORTANT: CUDA/Driver Compatibility
# - Driver 580.x supports CUDA 13.0
# - Using cu130-nightly tag for CUDA 13.0 compatibility
# - This fixes "Error 803: unsupported display driver / cuda driver combination"
#
# NOTE: GLM-4.7-Flash uses model type 'glm4_moe_lite' which is only in
# transformers main branch (not yet released in 4.x or 5.x stable)

FROM vllm/vllm-openai:cu130-nightly

# Install transformers from main branch for GLM-4.7-Flash support
# - GLM-4.7-Flash (glm4_moe_lite) requires unreleased transformers
# - Pin numpy to avoid lmcache/numba compatibility issues
# - Install git temporarily for pip install from GitHub
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    pip install --no-cache-dir "numpy>=1.24,<2.3" && \
    pip install --no-cache-dir git+https://github.com/huggingface/transformers.git@main && \
    apt-get purge -y git && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    python3 -c "import transformers; print(f'Transformers {transformers.__version__} installed successfully')"

# Set default environment variables
ENV HF_HOME=/root/.cache/huggingface
