#!/bin/bash
# shellcheck source=./helpers.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"
REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"

setup_podman() {
  section "🐋" "Podman Machine" "$MAGENTA"
  bash "$REPO_ROOT/src/scripts/setup_podman.sh"
}
