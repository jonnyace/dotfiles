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
- `packages/linux-arch-aur.txt`: reviewed AUR packages installed with `paru` or
  `yay`.
- `legacy/stow-linux/`: previous Stow/Omarchy configuration retained as an
  ignored migration reference. It is not applied by Chezmoi.

Hyprland and Foot are managed only on Linux. Ghostty is managed only on macOS.
Neovim and most shell behavior are shared.

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

After installing Homebrew, install Chezmoi, initialize this repository, install
the declared packages, review the diff, and then apply:

```sh
brew install chezmoi
chezmoi init jonnyace/dotfiles
~/.local/share/chezmoi/bootstrap.sh
chezmoi diff
chezmoi apply --interactive
```

The package bootstrap installs Ghostty, 1Password with its CLI, and the
standalone Tailscale app on macOS. On Arch Linux it installs Tailscale from the
official repository and 1Password with its CLI from the AUR. It does not sign
in to accounts, change the default browser, adopt existing files, or apply
dotfiles automatically.

After package installation, finish the security-sensitive setup interactively:

- In 1Password, sign in and enable **Settings > Developer > Integrate with
  1Password CLI**. Enable the SSH agent there if you want 1Password-managed SSH
  keys.
- On macOS, open Tailscale, approve its network extension and VPN configuration,
  sign in, then use **Settings > CLI integration** to install the `tailscale`
  command.
- On Arch Linux, enable Tailscale with `sudo systemctl enable --now tailscaled`,
  then authenticate with `sudo tailscale up`.

## Local and sensitive state

Git credential helpers, tokens, API keys, and machine-local files should not be
committed. This repository deliberately does not manage `~/.gitconfig`, so an
existing GitHub credential setup is preserved.
