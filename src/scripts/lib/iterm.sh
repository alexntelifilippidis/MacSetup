#!/bin/bash
# shellcheck source=./helpers.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"
REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"

# iTerm2 "Batman"/"Default" profiles created by hand before this repo took over —
# same names as the Dynamic Profiles below but different Guids, so iTerm2 won't
# merge them. Left in place they show up as confusing duplicates in the profile
# list. One-time cleanup only; safe to delete this once you've done it.
_ITERM_LEGACY_BATMAN_GUID="67C07598-05F6-4735-B887-6EA0F0215442"
_ITERM_LEGACY_DEFAULT_GUID="76C50B9B-EC7A-4676-91B1-49BCB29C5117"

_iterm_warn_legacy_profiles() {
  local prefs="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
  [ -f "$prefs" ] || return 0

  if grep -q "$_ITERM_LEGACY_BATMAN_GUID\|$_ITERM_LEGACY_DEFAULT_GUID" "$prefs" 2> /dev/null; then
    echo -e "  ${YELLOW}⚠️  Legacy manually-created 'Batman'/'Default' profiles still in iTerm2 prefs${RESET}"
    echo -e "  ${YELLOW}   Quit iTerm2, then: Preferences → Profiles → select each → Other Actions → Delete Profile${RESET}"
  fi
}

# Deploys the repo-managed Dynamic Profiles (Batman + Default, colors from the
# official Batman iTerm2 scheme) so iTerm2 profile config lives in the repo
# instead of the app's binary prefs. iTerm2 file-watches this directory — no
# restart needed, changes apply the moment the symlink target changes.
setup_iterm() {
  section "🖥️" "iTerm2 Dynamic Profiles" "$MAGENTA"

  local profiles_dir="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
  mkdir -p "$profiles_dir"
  symlink_if_changed "$REPO_ROOT/src/dotfiles/iterm2/DynamicProfiles/batcave.json" "$profiles_dir/batcave.json"

  # Batman profile's background image. Deliberately NOT inside DynamicProfiles/ —
  # iTerm2 tries to JSON-parse every file in that directory, and a symlinked .png
  # there fails that parse on every launch/rescan ("contains invalid JSON").
  # batcave.json's "Background Image Location" points at this exact deployed path.
  local images_dir="$HOME/Library/Application Support/iTerm2/images"
  mkdir -p "$images_dir"
  symlink_if_changed "$REPO_ROOT/src/dotfiles/iterm2/assets/batman-bg.png" "$images_dir/batman-bg.png"

  # One-time cleanup: earlier versions symlinked the .png straight into
  # DynamicProfiles/, tripping iTerm2's profile-JSON parser. Remove that stray link.
  if [ -L "$profiles_dir/batman-bg.png" ]; then
    rm -f "$profiles_dir/batman-bg.png"
  fi

  _iterm_warn_legacy_profiles
}
