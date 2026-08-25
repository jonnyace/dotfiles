# Cross-platform dotfiles

One [Chezmoi](https://www.chezmoi.io/) repository for macOS and Arch Linux.
Shared configuration lives in one place, while operating-system differences
remain explicit and reviewable. GNU Stow is no longer used.

## Platform split

| Area | macOS | Arch Linux |
| --- | --- | --- |
| Terminal | Ghostty | Foot |
| Packages | Homebrew Bundle | `pacman`, plus reviewed AUR packages |
| Desktop security | 1Password and Tailscale standalone apps | 1Password from AUR and Tailscale from `extra` |
| Desktop config | Ghostty | Foot and Hyprland |

Neovim, shell behavior, command-line tools, OpenCode, and most configuration
are shared.

## One-line installation

On a new macOS or Arch Linux machine:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/jonnyace/dotfiles/main/install.sh)"
```

The script installs missing prerequisites (Homebrew and Chezmoi on macOS; Git
and Chezmoi on Arch), then runs `chezmoi init --apply --interactive`. Chezmoi
installs packages from the manifests first, then prompts before writing
dotfiles.

Arch Linux still needs `paru` or `yay` first, because those are required for
the 1Password packages. Codex stays outside this installer; use the standalone
command in the platform sections below.

The same Chezmoi commands are written out per platform if you prefer to run
them by hand.

## New macOS machine

[Install Homebrew](https://brew.sh/), then run:

```sh
brew install chezmoi
chezmoi init --apply --interactive jonnyace/dotfiles
```

To review the diff before applying, split that into:

```sh
brew install chezmoi
chezmoi init jonnyace/dotfiles
chezmoi diff
chezmoi apply --interactive
```

Install the [Codex CLI](https://learn.chatgpt.com/docs/codex/cli) separately with
OpenAI's standalone installer, then sign in with ChatGPT when prompted:

```sh
curl -fsSL https://chatgpt.com/codex/install.sh | sh
codex
```

## New Arch Linux machine

Install Git, Chezmoi, and either `paru` or `yay` before bootstrapping. The AUR
helper is required for the 1Password desktop and CLI packages.

```sh
sudo pacman -S --needed git chezmoi
chezmoi init --apply --interactive jonnyace/dotfiles
```

To review the diff before applying, split that into:

```sh
sudo pacman -S --needed git chezmoi
chezmoi init jonnyace/dotfiles
chezmoi diff
chezmoi apply --interactive
```

Install Codex with the same standalone installer used on macOS:

```sh
curl -fsSL https://chatgpt.com/codex/install.sh | sh
codex
```

## Existing machine

Pull package and configuration updates without applying dotfiles automatically.
Rerunning the one-line installer does the same pull, then applies
interactively.

```sh
chezmoi git pull -- --ff-only
chezmoi diff
chezmoi apply --interactive
```

## Installed tools

Chezmoi runs `run_onchange_before_install-packages.sh.tmpl` during apply, which
installs the following shared environment:

- Dotfiles and source control: Chezmoi, Git, GitHub CLI, and Lazygit.
- Search and navigation: ripgrep, `fd`, `fzf`, Zoxide, Eza, and `tree`.
- Data and scripting: `jq`, Node.js, Python, and Pipx.
- Editor tooling: Neovim, Tree-sitter CLI, Stylua, Shfmt, and ShellCheck.
- System tools: Btop and Fastfetch.
- Coding agents: OpenCode. Codex is kept outside the OS package manifests;
  rerun its official standalone installer to update it.
- Security and networking: 1Password desktop and CLI, plus Tailscale.

macOS additionally installs Ghostty. Arch Linux additionally installs Foot and
its terminfo package. The package lists are the source of truth:

- `packages/darwin.Brewfile`
- `packages/linux-arch.txt`
- `packages/linux-arch-aur.txt`

Changing a manifest re-runs the package script on the next apply.

## Required interactive setup

Chezmoi installs software but deliberately does not authenticate accounts or
approve security-sensitive operating-system permissions.

### 1Password

1. Open 1Password and sign in.
2. Open **Settings > Developer** and enable **Integrate with 1Password CLI**.
3. Optionally enable the 1Password SSH agent for keys stored in 1Password.
4. Verify CLI access with `op vault list`.

Configure macOS and Safari AutoFill from 1Password settings. Extensions for
other browsers should be installed interactively from the browser's official
extension store.

### Tailscale on macOS

1. Open Tailscale and approve the network extension and VPN configuration.
2. Sign in to the intended tailnet.
3. Open **Settings > CLI integration**, select **Show me how**, and install the
   `tailscale` command when prompted for an administrator password.
4. Verify the connection with `tailscale status`.

### Tailscale on Arch Linux

```sh
sudo systemctl enable --now tailscaled
sudo tailscale up
tailscale status
```

## Repository layout

- `install.sh`: installs Chezmoi if needed, then runs `chezmoi init --apply`.
- `run_onchange_before_install-packages.sh.tmpl`: package install during apply.
- `dot_*` and `dot_config/`: active Chezmoi-managed files.
- `.chezmoitemplates/shell/`: shared, macOS, and Linux shell fragments.
- `packages/`: declarative package manifests read by the apply script.
- `legacy/stow-linux/`: ignored migration reference from the previous Stow and
  Omarchy layout; Chezmoi does not apply it.

## Safety and sensitive state

Always inspect `chezmoi diff` before applying, or use `--interactive` so Chezmoi
prompts before each change. Package installation runs as a before-apply script;
it does not adopt existing files, change the default browser, sign in to
accounts, or approve VPN and security permissions.

Do not commit API keys, tokens, passwords, Git credentials, or machine-local
state. This repository deliberately does not manage `~/.gitconfig`, preserving
the machine's existing GitHub credential setup.
