# vLLM with latest transformers for GLM-4.7-Flash support
# Based on official vllm-openai image with updated transformers

FROM vllm/vllm-openai:latest

# Install git (required for pip install from git) and update transformers
# GLM-4.7-Flash uses model type 'glm4_moe_lite' which requires latest transformers
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    pip install --no-cache-dir git+https://github.com/huggingface/transformers.git && \
    apt-get remove -y git && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set default environment variables
ENV HF_HOME=/root/.cache/huggingface
