#!/bin/sh
# vLLM entrypoint wrapper
# Injects --override-generation-config before all other args.
# Single quotes here are handled by the shell correctly — no docker-compose quoting issues.
exec python3 -m vllm.entrypoints.openai.api_server \
    --override-generation-config '{"enable_thinking": false}' \
    "$@"
