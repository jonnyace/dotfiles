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

    aur_packages=()
    while IFS= read -r package; do
      [[ -z "$package" || "$package" == \#* ]] && continue
      aur_packages+=("$package")
    done < "$repo_dir/packages/linux-arch-aur.txt"

    if ((${#aur_packages[@]})); then
      if command -v paru >/dev/null 2>&1; then
        paru -S --needed "${aur_packages[@]}"
      elif command -v yay >/dev/null 2>&1; then
        yay -S --needed "${aur_packages[@]}"
      else
        echo "1Password packages require an AUR helper (paru or yay)." >&2
        echo "Review packages/linux-arch-aur.txt, install a helper, and rerun this script." >&2
        exit 1
      fi
    fi
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
