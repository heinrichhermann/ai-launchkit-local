# vLLM with latest transformers for GLM-4.7-Flash support
# Based on official vllm-openai image with updated transformers

FROM vllm/vllm-openai:latest

# Install latest transformers for GLM-4.7-Flash support
# GLM-4.7-Flash uses model type 'glm4_moe_lite' which requires transformers from main branch
# 
# The vllm base image doesn't include git, so we:
# 1. Install git temporarily
# 2. Install transformers from GitHub main branch
# 3. Remove git to keep image size small
# 4. Verify the installation worked
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    pip install --no-cache-dir --force-reinstall git+https://github.com/huggingface/transformers.git@main && \
    apt-get purge -y git && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    python -c "from transformers import AutoConfig; print('Transformers installed successfully')"

# Set default environment variables
ENV HF_HOME=/root/.cache/huggingface
