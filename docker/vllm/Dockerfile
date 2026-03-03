# vLLM with latest transformers for GLM-4.7-Flash support
# Based on official vllm-openai image with updated transformers

FROM vllm/vllm-openai:latest

# Install latest transformers from git for GLM-4.7-Flash support
# GLM-4.7-Flash uses model type 'glm4_moe_lite' which requires latest transformers
RUN pip install --no-cache-dir git+https://github.com/huggingface/transformers.git

# Set default environment variables
ENV HF_HOME=/root/.cache/huggingface
