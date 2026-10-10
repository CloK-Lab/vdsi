#!/usr/bin/env bash
set -euo pipefail

# Run from the repository root, including when invoked from another directory.
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

lake build
lake exe tests
lake env lean scripts/Audit.lean

echo "All system checks passed: build, tests, and axiom audit."
