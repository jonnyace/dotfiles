#!/usr/bin/env bash
# One-shot installer for macOS and Arch Linux.
# Safe to pipe:
#   curl -fsSL https://raw.githubusercontent.com/jonnyace/dotfiles/main/install.sh | bash

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
  [[ -f "$dir/bootstrap.sh" ]] || return 1
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

init_source() {
  local local_repo
  if local_repo="$(repo_dir_from_script)"; then
    echo "Using local repository $local_repo"
    cd "$local_repo"
    return
  fi

  local source_path=""
  if have chezmoi; then
    source_path="$(chezmoi source-path 2>/dev/null || true)"
  fi

  if [[ -n "$source_path" && -d "$source_path/.git" ]]; then
    local origin
    origin="$(git -C "$source_path" remote get-url origin 2>/dev/null || true)"
    if ! origin_is_this_repo "$origin"; then
      echo "chezmoi is already initialized from ${origin:-an unknown repository}." >&2
      echo "Refusing to overwrite it." >&2
      exit 1
    fi
    echo "Updating $source_path"
    git -C "$source_path" pull --ff-only
    cd "$source_path"
    return
  fi

  echo "Initializing chezmoi from $repo"
  chezmoi init "$repo"
  cd "$(chezmoi source-path)"
}

ensure_prereqs
init_source
./bootstrap.sh
