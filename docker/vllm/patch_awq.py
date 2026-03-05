"""
Patch vLLM compressed-tensors quantization to handle fused layers.

vLLM 0.16.x introduced DeepSeekV2FusedQkvAProj for GLM-4.7-Flash's
fused_qkv_a_proj layer. AWQ quant configs only have targets for the
original q_a_proj / kv_a_proj names — not the fused version — causing:

  ValueError: Unable to find matching target for
    model.layers.X.self_attn.fused_qkv_a_proj in the compressed-tensors config.

Fix: wrap get_scheme() in a try/except so unmatched layers return None
(= no quantization, runs in BF16). All other layers stay AWQ-quantized.

Uses dynamic indentation detection to work across different vLLM versions.
"""
import pathlib
import sys

CT_FILE = pathlib.Path(
    "/usr/local/lib/python3.12/dist-packages/vllm/model_executor"
    "/layers/quantization/compressed_tensors/compressed_tensors.py"
)

NEEDLE = "quant_scheme = self.get_scheme(layer=layer, layer_name=prefix)"

if not CT_FILE.exists():
    print(f"ERROR: {CT_FILE} not found", file=sys.stderr)
    sys.exit(1)

lines = CT_FILE.read_text().splitlines(keepends=True)

patched = False
for i, line in enumerate(lines):
    if NEEDLE in line and "try:" not in lines[max(0, i - 1)]:
        # Detect actual indentation from this line
        indent = len(line) - len(line.lstrip())
        pad = " " * indent
        inner = " " * (indent + 4)

        lines[i] = (
            f"{pad}try:\n"
            f"{inner}quant_scheme = self.get_scheme(layer=layer, layer_name=prefix)\n"
            f"{pad}except ValueError:\n"
            f"{inner}# fused_qkv_a_proj has no AWQ target -> run unquantized (BF16)\n"
            f"{inner}return None\n"
        )
        patched = True
        print(f"OK: patched line {i + 1} (indent={indent}) — "
              "fused_qkv_a_proj runs unquantized (BF16)")
        break

if not patched:
    print("WARNING: patch target not found in compressed_tensors.py — "
          "already patched or code changed. Skipping.")
