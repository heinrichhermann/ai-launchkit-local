"""
Patch vLLM compressed-tensors to fix UnboundLocalError for UnquantizedLinearMethod.

vLLM 0.17.2rc1 nightly has a Python scoping bug in compressed_tensors.py where
UnquantizedLinearMethod is conditionally imported inside a function body, making
Python treat it as a local variable throughout the entire function. When the
variable isn't assigned (because the conditional branch wasn't taken), accessing
it raises UnboundLocalError.

Fix: Add 'from vllm.model_executor.layers.linear import UnquantizedLinearMethod'
at the MODULE level so it's always available as a module-level name.

This also covers the fused_qkv_a_proj ValueError fix for GLM-4.7-Flash AWQ.
"""
import pathlib
import py_compile
import sys

CT_FILE = pathlib.Path(
    "/usr/local/lib/python3.12/dist-packages/vllm/model_executor"
    "/layers/quantization/compressed_tensors/compressed_tensors.py"
)

if not CT_FILE.exists():
    print(f"ERROR: {CT_FILE} not found", file=sys.stderr)
    sys.exit(1)

content = CT_FILE.read_text()

# Check if UnquantizedLinearMethod is already imported at module level
if "from vllm.model_executor.layers.linear import UnquantizedLinearMethod" in content:
    print("UnquantizedLinearMethod already imported at module level — skipping.")
else:
    # Add module-level import after the existing linear imports (or at end of imports)
    # Find a good insertion point: after the last 'from vllm' import line
    lines = content.splitlines(keepends=True)
    insert_at = 0
    for i, line in enumerate(lines):
        if line.startswith("from vllm") or line.startswith("import vllm"):
            insert_at = i + 1

    if insert_at == 0:
        print("WARNING: Could not find insertion point, prepending import.")
        lines.insert(0, "from vllm.model_executor.layers.linear import UnquantizedLinearMethod\n")
    else:
        lines.insert(insert_at, "from vllm.model_executor.layers.linear import UnquantizedLinearMethod  # patch: fix UnboundLocalError\n")

    CT_FILE.write_text("".join(lines))
    print(f"OK: added UnquantizedLinearMethod import at line {insert_at + 1}")

# Invalidate .pyc cache
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
