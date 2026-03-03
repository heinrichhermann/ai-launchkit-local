# vLLM with latest transformers for GLM-4.7-Flash support
# Based on official vllm-openai image with updated transformers

FROM vllm/vllm-openai:latest

# Install latest transformers for GLM-4.7-Flash support
# GLM-4.7-Flash uses model type 'glm4_moe_lite' which requires latest transformers
# Using tarball URL instead of git+ to avoid git dependency
RUN pip install --no-cache-dir https://github.com/huggingface/transformers/archive/refs/heads/main.zip

# Set default environment variables
ENV HF_HOME=/root/.cache/huggingface
