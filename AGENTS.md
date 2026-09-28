# Dotfiles maintenance safety

## Desktop input hooks

`skhd`, OmniWM, and yabai install global macOS event taps. Never install,
reinstall, upgrade, unlink, or replace their binaries while the corresponding
process is running. Replacing a live event-tap executable can invalidate macOS
Accessibility state and leave local keyboard or pointer input unresponsive.

Prefer `dot update`, which suspends these services around Homebrew changes. For
targeted package maintenance, preserve the active mode shown by
`desktop-wm status`, run `desktop-wm stop` before invoking Homebrew, and restore
the previous mode with `desktop-wm omniwm` or `desktop-wm yabai` afterward.

If local input is already unresponsive, run `desktop-wm stop` from a remote
session before attempting any other recovery.
