"""
Patch vLLM compressed-tensors quantization to handle fused layers.

vLLM 0.16.x introduced DeepSeekV2FusedQkvAProj for GLM-4.7-Flash's
fused_qkv_a_proj layer. AWQ quant configs only have targets for the
original q_a_proj / kv_a_proj names — not the fused version — causing:

  ValueError: Unable to find matching target for
    model.layers.X.self_attn.fused_qkv_a_proj in the compressed-tensors config.

Fix: wrap get_scheme() in a try/except so unmatched layers return None
(= no quantization, runs in BF16). All other layers stay AWQ-quantized.

Also deletes the .pyc bytecode cache so Python uses the patched source.
"""
import pathlib
import py_compile
import shutil
import sys

CT_FILE = pathlib.Path(
    "/usr/local/lib/python3.12/dist-packages/vllm/model_executor"
    "/layers/quantization/compressed_tensors/compressed_tensors.py"
)

NEEDLE = "quant_scheme = self.get_scheme(layer=layer, layer_name=prefix)"

if not CT_FILE.exists():
    print(f"ERROR: {CT_FILE} not found", file=sys.stderr)
    sys.exit(1)

# --- Diagnostics: show lines around the target ---
lines = CT_FILE.read_text().splitlines(keepends=True)
print(f"File has {len(lines)} lines. Searching for NEEDLE...")
found_at = [i for i, l in enumerate(lines) if NEEDLE in l]
print(f"NEEDLE found at lines (0-indexed): {found_at}")
for idx in found_at:
    lo = max(0, idx - 2)
    hi = min(len(lines), idx + 3)
    for j in range(lo, hi):
        marker = ">>>" if j == idx else "   "
        print(f"  {marker} {j+1}: {repr(lines[j])}")

# --- Apply patch ---
patched = False
for i, line in enumerate(lines):
    if NEEDLE in line and "try:" not in lines[max(0, i - 1)]:
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
        print(f"OK: patched line {i + 1} (indent={indent})")
        break

if not patched:
    print("WARNING: patch target not found or already patched. Skipping.")
    sys.exit(0)

CT_FILE.write_text("".join(lines))
print("Written patched source.")

# --- Invalidate .pyc bytecode cache so Python uses the patched .py ---
cache_dir = CT_FILE.parent / "__pycache__"
if cache_dir.exists():
    removed = []
    for pyc in cache_dir.glob("compressed_tensors*.pyc"):
        pyc.unlink()
        removed.append(pyc.name)
    if removed:
        print(f"Removed stale .pyc files: {removed}")

# Re-compile so the patched bytecode is used from the start
py_compile.compile(str(CT_FILE), doraise=True)
print(f"Re-compiled {CT_FILE.name} — patch active.")
