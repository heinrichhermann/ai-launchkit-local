# vLLM with compatible transformers for GLM-4.7-Flash support
# Based on official vllm-openai image
#
# IMPORTANT: CUDA/Driver Compatibility
# - Driver 580.x supports CUDA 13.0
# - Using cu130-nightly tag for CUDA 13.0 compatibility
# - This fixes "Error 803: unsupported display driver / cuda driver combination"
#
# NOTE: vLLM 0.16.x requires transformers<5, so we use the latest 4.x release
# GLM-4.7-Flash is supported in transformers 4.57+

FROM vllm/vllm-openai:cu130-nightly

# Upgrade transformers to latest 4.x for GLM-4.7-Flash support
# - vLLM requires transformers<5,>=4.56.0
# - GLM-4.7-Flash (glm4_moe_lite) is supported in transformers 4.57+
# - Using --upgrade to get latest compatible version
RUN pip install --no-cache-dir --upgrade "transformers>=4.57,<5" && \
    python3 -c "import transformers; print(f'Transformers {transformers.__version__} installed successfully')"

# Set default environment variables
ENV HF_HOME=/root/.cache/huggingface
