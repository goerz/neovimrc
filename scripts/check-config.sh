#!/usr/bin/env bash
# Load this Neovim config headlessly and fail if it produces any errors or
# warnings. Useful for smoke-testing the config against a different Neovim
# version before committing to it.
#
# Usage:
#   scripts/check-config.sh                 # use `nvim` from PATH
#   scripts/check-config.sh /path/to/nvim   # use a specific binary
#   NVIM=/path/to/nvim scripts/check-config.sh
#
# Exit status is 0 on success, nonzero on any load error/warning or if the
# binary itself writes to stderr during startup.

set -uo pipefail

NVIM="${1:-${NVIM:-nvim}}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v "$NVIM" >/dev/null 2>&1 && [ ! -x "$NVIM" ]; then
  echo "error: nvim binary not found: $NVIM" >&2
  exit 2
fi

echo "== $("$NVIM" --version | head -1) =="

# Capture stdout and stderr separately: our checker prints results to stdout and
# calls :cquit on failure; genuine startup errors from Neovim go to stderr.
err_file="$(mktemp)"
trap 'rm -f "$err_file"' EXIT

"$NVIM" --headless \
  -c "luafile $HERE/healthcheck.lua" \
  -c "qa" \
  2>"$err_file"
status=$?

if [ -s "$err_file" ]; then
  echo "--- stderr ---"
  cat "$err_file"
  status=1
fi

if [ "$status" -eq 0 ]; then
  echo "PASS"
else
  echo "FAILED (exit $status)"
fi
exit "$status"
