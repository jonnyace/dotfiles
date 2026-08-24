#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
  Darwin)
    if ! command -v brew >/dev/null 2>&1; then
      echo "Homebrew is required. Install it from https://brew.sh and rerun this script." >&2
      exit 1
    fi
    brew bundle --file "$repo_dir/packages/darwin.Brewfile"
    ;;
  Linux)
    if [[ ! -r /etc/arch-release ]]; then
      echo "Only Arch Linux package bootstrapping is currently supported." >&2
      exit 1
    fi
    packages=()
    while IFS= read -r package; do
      [[ -z "$package" || "$package" == \#* ]] && continue
      packages+=("$package")
    done < "$repo_dir/packages/linux-arch.txt"
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    ;;
  *)
    echo "Unsupported operating system: $(uname -s)" >&2
    exit 1
    ;;
esac

echo
echo "Packages are ready. Review the proposed dotfile changes with:"
printf '  chezmoi --source %q diff\n' "$repo_dir"
echo
echo "Apply only after reviewing the diff:"
printf '  chezmoi --source %q apply --interactive\n' "$repo_dir"
