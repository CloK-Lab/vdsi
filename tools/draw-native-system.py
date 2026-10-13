"""Compatibility entry point for the Hairline notebook diagram generator."""
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parents[1]
subprocess.run(["node", str(root / "tools/draw-hairline-figures.mjs")], cwd=root, check=True)
