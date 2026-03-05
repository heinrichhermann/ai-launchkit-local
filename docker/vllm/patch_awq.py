"""
Patch vLLM compressed-tensors quantization to handle fused layers.

vLLM 0.16.x introduced DeepSeekV2FusedQkvAProj for GLM-4.7-Flash's
fused_qkv_a_proj layer. AWQ quant configs only have targets for the
original q_a_proj / kv_a_proj names — not the fused version — causing:

  ValueError: Unable to find matching target for
    model.layers.X.self_attn.fused_qkv_a_proj in the compressed-tensors config.

Fix: wrap get_scheme() in a try/except so unmatched layers return None
(= no quantization, runs in BF16). All other layers stay AWQ-quantized.
"""
import pathlib
import sys

CT_FILE = pathlib.Path(
    "/usr/local/lib/python3.12/dist-packages/vllm/model_executor"
    "/layers/quantization/compressed_tensors/compressed_tensors.py"
)

if not CT_FILE.exists():
    print(f"ERROR: {CT_FILE} not found", file=sys.stderr)
    sys.exit(1)

code = CT_FILE.read_text()

OLD = "        quant_scheme = self.get_scheme(layer=layer, layer_name=prefix)"
NEW = (
    "        try:\n"
    "            quant_scheme = self.get_scheme(layer=layer, layer_name=prefix)\n"
    "        except ValueError:\n"
    "            # fused_qkv_a_proj has no AWQ target -> run unquantized (BF16)\n"
    "            return None"
)

if OLD not in code:
    print("WARNING: patch target not found in compressed_tensors.py — "
          "vLLM code may have changed. Skipping patch.")
    sys.exit(0)

CT_FILE.write_text(code.replace(OLD, NEW, 1))
print("OK: patched compressed_tensors.py — fused_qkv_a_proj runs unquantized (BF16)")
