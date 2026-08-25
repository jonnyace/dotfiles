#!/usr/bin/env bash
# One-shot installer for macOS and Arch Linux.
# Prefers a TTY so chezmoi --interactive prompts work:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/jonnyace/dotfiles/main/install.sh)"

set -euo pipefail

repo="jonnyace/dotfiles"

have() {
  command -v "$1" >/dev/null 2>&1
}

repo_dir_from_script() {
  local src="${BASH_SOURCE[0]:-}"
  [[ -n "$src" && -f "$src" ]] || return 1
  local dir
  dir="$(cd "$(dirname "$src")" && pwd)"
  [[ -d "$dir/packages" && -f "$dir/run_onchange_before_install-packages.sh.tmpl" ]] || return 1
  printf '%s\n' "$dir"
}

load_homebrew() {
  if have brew; then
    return
  fi
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

ensure_homebrew() {
  load_homebrew
  if have brew; then
    return
  fi

  echo "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  load_homebrew
  if ! have brew; then
    echo "Homebrew installed but brew is not on PATH." >&2
    exit 1
  fi
}

ensure_prereqs() {
  case "$(uname -s)" in
    Darwin)
      ensure_homebrew
      if ! have git || ! have chezmoi; then
        brew install git chezmoi
      fi
      ;;
    Linux)
      if [[ ! -r /etc/arch-release ]]; then
        echo "Only Arch Linux package bootstrapping is currently supported." >&2
        exit 1
      fi
      if ! have git || ! have chezmoi; then
        sudo pacman -S --needed --noconfirm git chezmoi
      fi
      if ! have paru && ! have yay; then
        echo "1Password packages require an AUR helper (paru or yay)." >&2
        echo "Install one, then rerun this script." >&2
        exit 1
      fi
      ;;
    *)
      echo "Unsupported operating system: $(uname -s)" >&2
      exit 1
      ;;
  esac
}

origin_is_this_repo() {
  local origin="$1"
  [[ "$origin" == *"$repo"* ]]
}

prompt_tty() {
  if [[ -r /dev/tty ]]; then
    "$@" </dev/tty
  else
    "$@"
  fi
}

apply_with_chezmoi() {
  local local_repo=""
  local source_path=""
  local origin=""

  if local_repo="$(repo_dir_from_script)"; then
    echo "Initializing chezmoi from $local_repo"
    prompt_tty chezmoi init --apply --interactive --source "$local_repo"
    return
  fi

  source_path="$(chezmoi source-path 2>/dev/null || true)"
  if [[ -n "$source_path" && -d "$source_path/.git" ]]; then
    origin="$(git -C "$source_path" remote get-url origin 2>/dev/null || true)"
    if ! origin_is_this_repo "$origin"; then
      echo "chezmoi is already initialized from ${origin:-an unknown repository}." >&2
      echo "Refusing to overwrite it." >&2
      exit 1
    fi
    echo "Updating $source_path"
    chezmoi git pull -- --ff-only
    prompt_tty chezmoi apply --interactive
    return
  fi

  echo "Initializing chezmoi from $repo"
  prompt_tty chezmoi init --apply --interactive "$repo"
}

ensure_prereqs
apply_with_chezmoi
