# 🖥️ iTerm2

Repo-managed iTerm2 profiles via [Dynamic Profiles](https://iterm2.com/documentation-dynamic-profiles.html)
— the profile config lives in this repo as JSON, not hand-edited in iTerm2's UI, so it's
versioned and reviewable like everything else here.

## Files

- **`DynamicProfiles/batcave.json`**: defines two profiles —
  - **Batman**: colors from the official
    [Batman iTerm2 scheme](https://github.com/mbadolato/iTerm2-Color-Schemes/blob/master/terminal/Batman.terminal),
    font [Inconsolata Nerd Font Mono](https://www.nerdfonts.com/font-downloads) (`InconsolataNFM-Regular 15`),
    background image `assets/batman-bg.png` (the bat-signal logo, `Blend` kept low so it
    reads as a faint watermark, not a wall of yellow behind your text)
  - **Default**: iTerm2's stock look
- **`assets/batman-bg.png`**: the Batman profile's background image

## What the Setup Does

`setup_iterm` (`src/scripts/lib/iterm.sh`) symlinks `batcave.json` into
`~/Library/Application Support/iTerm2/DynamicProfiles/` and `batman-bg.png` into a
sibling `~/Library/Application Support/iTerm2/images/` directory (deliberately **not**
`DynamicProfiles/` — iTerm2 tries to JSON-parse every file it finds in that directory,
and a symlinked `.png` there fails that parse on every launch, logging "contains invalid
JSON" repeatedly). iTerm2 file-watches `DynamicProfiles/`, so JSON changes apply
immediately — no restart needed. The font itself is a Homebrew cask
(`font-inconsolata-nerd-font` in the root `Brewfile`) — the full Nerd Font patch, not a
plain `-for-powerline` cask, since the batman zsh theme's glyphs span Font Awesome,
Material Design, and Powerline icon sets, not just Powerline.

## Both Profiles Are `"Rewritable": false`

iTerm2 lets you edit a Dynamic Profile's fields from Preferences if a profile is
`Rewritable`, but for one entry inside a multi-profile array file like this one, it
can't safely patch that one entry in place — instead it forks the *entire* profile out
into a **new standalone file** (this happened once already: iTerm2 wrote a full
`Batman.json` next to `batcave.json`, reducing `batcave.json`'s own copy to a bare
Name/Guid stub). `Rewritable` is now `false` on both profiles specifically to stop that
fork from recurring — `batcave.json` is the only place either profile is edited from
here on. If you want to try a color/font/image tweak interactively first, do it on an
unrelated scratch profile, then hand-port the JSON diff into `batcave.json`.

## Live Sync With the Zsh Theme

`.zshrc` reads `$HOME/.config/theme` (the same file `make zsh-setup` writes) and emits an
iTerm2 proprietary escape code on shell start:

```bash
printf '\033]1337;SetProfile=%s\a' "Batman"   # or "Default"
```

Choosing the `batman` zsh theme switches the current iTerm2 session to the **Batman**
profile; any other theme (`kaizen`, `amuse`) switches it to **Default**. This only
affects sessions started *after* the theme changes — open tabs need a new shell
(`exec zsh`) or a new tab to pick it up.

## ⚠️ One-Time Manual Cleanup

If you followed the
[freeCodeCamp zsh guide](https://medium.com/free-code-camp/how-to-configure-your-macos-terminal-with-zsh-like-a-pro-c0ab3f3c1156)
and imported the Batman color preset by hand before this repo existed, iTerm2 has old
**regular** "Batman"/"Default" profiles with different Guids than the Dynamic Profiles
above — same names, so they'll show up as confusing duplicates. `setup_iterm` detects
this and prints a warning. To clean up: quit iTerm2, then Preferences → Profiles →
select each old one → **Other Actions → Delete Profile**.

## Editing Colors

Edit `DynamicProfiles/batcave.json` directly (any field from an iTerm2 profile export
is valid) — fields it defines are grayed out in iTerm2's UI, by design; the JSON is the
source of truth. Re-symlinking isn't needed after an edit, only after `mkdir`ing a fresh
`DynamicProfiles/` directory for the first time.

> ⚠️ `Background Image Location` is a real absolute path
> (`$HOME/Library/Application Support/iTerm2/images/batman-bg.png`), baked in at the
> value this machine's `$HOME` resolves to — unlike every other deployed dotfile in this
> repo, iTerm2's Dynamic Profile format has no `~`/env-var expansion. On a different Mac
> (different username), update that one field to match.
