#!/usr/bin/env bash
set -euo pipefail

# Run from the repository root, including when invoked from another directory.
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

lake build
lake exe tests
python3 Tests/identity_processes.py
python3 Tests/identity_registry_processes.py
python3 Tests/identity_exchange_processes.py
python3 Tests/node_processes.py
lake env lean scripts/Audit.lean

echo "All system checks passed: build, core tests, node processes, and axiom audit."
