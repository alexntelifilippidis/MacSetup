#!/usr/bin/env bash
# Runs shellcheck + shfmt validation on modified shell files before Claude edits are applied.
set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2> /dev/null || echo "")}"

if [[ -z "$REPO_ROOT" ]]; then
  echo "[validate-code] WARN: could not determine REPO_ROOT, skipping" >&2
  exit 0
fi

error=0

while IFS= read -r file; do
  [[ "$file" == *.sh ]] || continue
  [[ -f "$file" ]] || continue

  if ! shellcheck -x --severity=warning "$file"; then
    echo "[validate-code] FAIL: shellcheck failed on $file" >&2
    error=1
  fi

  if ! shfmt -i 2 -d "$file" > /dev/null; then
    echo "[validate-code] FAIL: shfmt diff on $file (run: shfmt -i 2 -w $file)" >&2
    error=1
  fi
done < <(git -C "$REPO_ROOT" diff --name-only HEAD 2> /dev/null)

exit "$error"
