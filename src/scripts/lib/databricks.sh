#!/bin/bash
# shellcheck source=./helpers.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"
REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"

setup_databricks() {
  section "🧪" "Databricks CLI Config" "$CYAN"
  chmod 600 "$REPO_ROOT/src/dotfiles/databricks/.databrickscfg"
  symlink_if_changed "$REPO_ROOT/src/dotfiles/databricks/.databrickscfg" "$HOME/.databrickscfg"
}
