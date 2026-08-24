# Cross-platform dotfiles

One Chezmoi repository for macOS and Linux. Shared configuration stays in one
place, while operating-system differences are explicit and testable.

## Why Chezmoi

Chezmoi provides a reviewable `diff`/`apply` workflow, OS-aware templates, and
safe handling of machine-specific configuration. GNU Stow is intentionally no
longer used by this repository.

## Layout

- `dot_*` and `dot_config/`: active Chezmoi-managed files.
- `.chezmoitemplates/shell/`: shared, macOS, and Linux shell fragments.
- `packages/darwin.Brewfile`: macOS command-line packages.
- `packages/linux-arch.txt`: Arch Linux command-line packages.
- `legacy/stow-linux/`: previous Stow/Omarchy configuration retained as an
  ignored migration reference. It is not applied by Chezmoi.

Hyprland is managed only on Linux. Neovim and most shell behavior are shared.
Alacritty uses an OS-aware template.

## Existing clone

Install or reconcile packages:

```sh
./bootstrap.sh
```

Always review before applying:

```sh
chezmoi --source "$PWD" diff
chezmoi --source "$PWD" apply --interactive
```

## New machine

Install Chezmoi, initialize this repository, review, and then apply:

```sh
chezmoi init jonnyace/dotfiles
chezmoi diff
chezmoi apply --interactive
```

The package bootstrap never installs desktop applications, changes the default
browser, adopts existing files, or applies dotfiles automatically.

## Local and sensitive state

Git credential helpers, tokens, API keys, and machine-local files should not be
committed. This repository deliberately does not manage `~/.gitconfig`, so an
existing GitHub credential setup is preserved.
