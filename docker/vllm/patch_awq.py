"""
Patch vLLM compressed-tensors to handle unmatched AWQ layers.

In vLLM 0.17.2rc1+ nightly, Qwen3.5-35B-A3B is treated as a VL model.
The VisionTransformer layers (e.g. visual.merger.linear_fc1) are not in
the AWQ quant config, so get_scheme() raises ValueError.

Fix: wrap get_scheme() in try/except and return an unquantized method for
unmatched layers. Vision layers run in BF16; all other layers stay AWQ-quantized.

IMPORTANT: Uses import alias '_ULM' to avoid Python 3.12 UnboundLocalError.
The scoping bug occurs when 'UnquantizedLinearMethod' is imported inside an
except block — Python treats it as local throughout the entire function,
causing UnboundLocalError if the try block succeeds. The alias sidesteps this.
"""
import pathlib
import py_compile
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
print(f"File has {len(lines)} lines. Searching for NEEDLE...")
found_at = [i for i, l in enumerate(lines) if NEEDLE in l]
print(f"NEEDLE found at lines (0-indexed): {found_at}")
for idx in found_at:
    lo = max(0, idx - 2)
    hi = min(len(lines), idx + 3)
    for j in range(lo, hi):
        marker = ">>>" if j == idx else "   "
        print(f"  {marker} {j+1}: {repr(lines[j])}")

patched = False
for i, line in enumerate(lines):
    if NEEDLE in line and "try:" not in lines[max(0, i - 1)]:
        indent = len(line) - len(line.lstrip())
        pad = " " * indent
        inner = " " * (indent + 4)

        lines[i] = (
            f"{pad}from vllm.model_executor.layers.linear import UnquantizedLinearMethod as _ULM\n"
            f"{pad}try:\n"
            f"{inner}quant_scheme = self.get_scheme(layer=layer, layer_name=prefix)\n"
            f"{pad}except ValueError:\n"
            f"{inner}# Layer not in AWQ config (e.g. VisionTransformer) → run unquantized (BF16)\n"
            f"{inner}return _ULM()\n"
        )
        patched = True
        print(f"OK: patched line {i + 1} (indent={indent})")
        break

if not patched:
    print("WARNING: patch target not found or already patched. Skipping.")
    sys.exit(0)

CT_FILE.write_text("".join(lines))
print("Written patched source.")

# Invalidate .pyc bytecode cache
cache_dir = CT_FILE.parent / "__pycache__"
if cache_dir.exists():
    removed = []
    for pyc in cache_dir.glob("compressed_tensors*.pyc"):
        pyc.unlink()
        removed.append(pyc.name)
    if removed:
        print(f"Removed stale .pyc files: {removed}")

py_compile.compile(str(CT_FILE), doraise=True)
print(f"Re-compiled {CT_FILE.name} — patch active.")
