"""
Robust state-aware patch for vLLM compressed_tensors.py AWQ quantization.

Problem: Qwen3.5-35B-A3B-AWQ has vision_config in config.json. vLLM's new
qwen3_5.py initializes Qwen3_VisionTransformer unconditionally. Vision layers
are not in AWQ quant config → get_quant_method() fails.

Root cause: get_scheme() raises ValueError for unmatched vision layer names.
The fix: wrap get_scheme() in try/except and return unquantized method.

Three states handled:
  1. _VLLM_ULM in file      → new correct patch already applied → skip
  2. Old broken patch found → local import inside function → REPLACE with correct patch
  3. Clean file             → ADD correct patch

The old broken patch added 'from ... import UnquantizedLinearMethod' INSIDE
the except block, causing Python 3.12 to treat the name as local throughout
the entire function → UnboundLocalError when try succeeds.

The new patch uses 'UnquantizedLinearMethod as _VLLM_ULM' as import alias,
which is a DIFFERENT name → no scoping conflict with module-level import.
"""
import pathlib
import py_compile
import sys

CT_FILE = pathlib.Path(
    "/usr/local/lib/python3.12/dist-packages/vllm/model_executor"
    "/layers/quantization/compressed_tensors/compressed_tensors.py"
)
NEEDLE = "quant_scheme = self.get_scheme(layer=layer, layer_name=prefix)"
NEW_SENTINEL = "_VLLM_ULM"
OLD_BROKEN_MARKER = "from vllm.model_executor.layers.linear import UnquantizedLinearMethod"

if not CT_FILE.exists():
    print(f"ERROR: {CT_FILE} not found", file=sys.stderr)
    sys.exit(1)

content = CT_FILE.read_text()
lines = content.splitlines(keepends=True)
print(f"File has {len(lines)} lines.")

# ── State detection ──────────────────────────────────────────────────────────

if NEW_SENTINEL in content:
    print(f"State 1: New correct patch already applied (_VLLM_ULM found). Nothing to do.")
    sys.exit(0)

# Find where get_quant_method function starts (approx line 140+)
func_start = 0
for i, l in enumerate(lines):
    if "def get_quant_method(" in l:
        func_start = i
        break

# Check if old broken patch is present: local import INSIDE the function
old_patch_line = None
for i in range(func_start, len(lines)):
    if OLD_BROKEN_MARKER in lines[i] and i > func_start:
        old_patch_line = i
        print(f"State 2: Old broken patch found at line {i+1}. Will replace.")
        break

if old_patch_line is None:
    print(f"State 3: Clean file. Will add new patch.")

# ── Find NEEDLE ──────────────────────────────────────────────────────────────

needle_idx = None
for i, l in enumerate(lines):
    if NEEDLE in l:
        needle_idx = i
        print(f"NEEDLE found at line {i+1}: {repr(l[:80])}")
        break

if needle_idx is None:
    print("ERROR: NEEDLE not found in file!", file=sys.stderr)
    sys.exit(1)

needle_line = lines[needle_idx]
# For State 3 (clean file): needle is at function body level (e.g. indent=8)
# For State 2 (old patch):  needle is INSIDE old try block (e.g. indent=12)
#   → we need try: at the OUTER indent (try_start indent), not the inner needle indent.
# We compute the NEW_BLOCK lazily after we know try_start (if applicable).

# ── Apply patch based on state ───────────────────────────────────────────────

if old_patch_line is not None:
    # State 2: Remove old broken try/except block and replace with new one.
    # The old block looks like:
    #   try:
    #       quant_scheme = self.get_scheme(...)
    #   except ValueError:
    #       from ... import UnquantizedLinearMethod
    #       return UnquantizedLinearMethod()
    # Find the start (the try: line before the needle)
    try_start = needle_idx
    for i in range(needle_idx - 1, max(0, needle_idx - 5), -1):
        if lines[i].strip() == "try:":
            try_start = i
            break

    # Find the end of the except block (next line with same or lower indent as try:)
    try_indent = len(lines[try_start]) - len(lines[try_start].lstrip())
    except_end = needle_idx + 1
    found_except = False
    for i in range(needle_idx + 1, min(len(lines), needle_idx + 10)):
        stripped = lines[i].strip()
        if stripped.startswith("except"):
            found_except = True
        if found_except:
            line_indent = len(lines[i]) - len(lines[i].lstrip()) if lines[i].strip() else 999
            if lines[i].strip() == "" or line_indent <= try_indent and not stripped.startswith("except") and not stripped.startswith("return") and not stripped.startswith("from"):
                except_end = i
                break
            except_end = i + 1

    # For State 2: use try_start indent for pad (NOT needle indent which is deeper)
    pad2 = " " * try_indent
    inner2 = " " * (try_indent + 4)
    NEW_BLOCK2 = (
        f"{pad2}from vllm.model_executor.layers.linear import UnquantizedLinearMethod as _VLLM_ULM\n"
        f"{pad2}try:\n"
        f"{inner2}{NEEDLE}\n"
        f"{pad2}except ValueError:\n"
        f"{inner2}# Layer not in AWQ config (e.g. VisionTransformer) → run unquantized (BF16)\n"
        f"{inner2}return _VLLM_ULM()\n"
    )
    print(f"Replacing old broken patch: lines {try_start+1}-{except_end} (try_indent={try_indent})")
    lines[try_start:except_end] = [NEW_BLOCK2]
else:
    # State 3: Clean file — needle is at function body level, use its indent
    needle_indent = len(needle_line) - len(needle_line.lstrip())
    pad3 = " " * needle_indent
    inner3 = " " * (needle_indent + 4)
    NEW_BLOCK3 = (
        f"{pad3}from vllm.model_executor.layers.linear import UnquantizedLinearMethod as _VLLM_ULM\n"
        f"{pad3}try:\n"
        f"{inner3}{NEEDLE}\n"
        f"{pad3}except ValueError:\n"
        f"{inner3}# Layer not in AWQ config (e.g. VisionTransformer) → run unquantized (BF16)\n"
        f"{inner3}return _VLLM_ULM()\n"
    )
    lines[needle_idx] = NEW_BLOCK3
    print(f"Added new patch at line {needle_idx+1} (needle_indent={needle_indent})")

CT_FILE.write_text("".join(lines))
print("Written patched source.")

# ── Invalidate .pyc cache ─────────────────────────────────────────────────────
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
