#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Config
# -----------------------------
APT_PKGS=(
  curl wget git vim tmux
  build-essential
  net-tools iputils-ping dnsutils traceroute tcpdump
  python3 python3-pip python3-venv
  fonts-powerline
  zsh
)

DOT_DIRS=( "zsh" "tmux" "vim" "dircolors")

ZSH_PLUGINS=(
  "https://github.com/zsh-users/zsh-autosuggestions"
  "https://github.com/zsh-users/zsh-syntax-highlighting"
)

# defaults
DOT_MODE="link"        # default
WSL_WARN=1             # default on

# -----------------------------
# Utils
# -----------------------------
log()  { echo -e "\033[1;32m[+]\033[0m $*"; }
warn() { echo -e "\033[1;33m[!]\033[0m $*"; }
err()  { echo -e "\033[1;31m[x]\033[0m $*" >&2; }

confirm() {
  local prompt="${1:-Continue?}"
  read -r -p "$prompt [y/N] " ans
  [[ "${ans:-}" =~ ^[Yy]$ ]]
}

script_dir() { cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd; }

is_wsl() {
  # WSL1/WSL2 공통 감지
  grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null
}

# sudo 인증을 "초반 1회"로 고정(권장)
sudo_prime() {
  if [ "${EUID}" -eq 0 ]; then
    return 0
  fi
  log "sudo 권한이 필요합니다. (비밀번호는 보통 1회만 입력)"
  sudo -v
}

# -----------------------------
# Arg parsing
# -----------------------------
while [ $# -gt 0 ]; do
  case "$1" in
    --copy) DOT_MODE="copy" ;;
    --link) DOT_MODE="link" ;;
    --wsl-warn) WSL_WARN=1 ;;
    --no-wsl-warn) WSL_WARN=0 ;;
    -h|--help)
      cat <<EOF
Usage: ./install.sh [options]
  --copy           copy dotfiles to \$HOME (default: link)
  --link           symlink dotfiles to \$HOME
  --wsl-warn        warn if running on WSL (default: on)
  --no-wsl-warn     disable WSL warning
EOF
      exit 0
      ;;
    *)
      err "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

# -----------------------------
# Safety: sudo로 실행했을 때 경고 + 확인
# -----------------------------
if [ "${EUID}" -eq 0 ]; then
  warn "현재 root로 실행 중입니다. (예: sudo ./install.sh)"
  warn "권장: ./install.sh (필요한 명령만 sudo 사용)"
  if ! confirm "그래도 계속 진행할까요?"; then
    err "중단합니다."
    exit 1
  fi
fi

# -----------------------------
# WSL warning
# -----------------------------
if [ "$WSL_WARN" -eq 1 ] && is_wsl; then
  warn "WSL 환경 감지됨."
  warn "프로젝트는 /mnt/c 가 아니라 /home 아래에서 작업하는 걸 권장합니다."
  warn "이 경고를 끄려면: --no-wsl-warn"
fi

ROOT_DIR="$(script_dir)"

# -----------------------------
# Steps
# -----------------------------
install_apt_packages() {
  sudo_prime
  log "APT update"
  sudo apt update -y
  log "Installing APT packages"
  sudo apt install -y "${APT_PKGS[@]}"
}

install_oh_my_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log "Installing oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  else
    warn "oh-my-zsh already installed"
  fi
}

install_zsh_plugins() {
  local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  mkdir -p "$zsh_custom/plugins"

  for repo in "${ZSH_PLUGINS[@]}"; do
    local name dest
    name="$(basename "$repo")"
    dest="$zsh_custom/plugins/$name"

    if [ -d "$dest" ]; then
      warn "zsh plugin exists: $name"
      continue
    fi

    log "Cloning zsh plugin: $name"
    git clone --depth 1 "$repo" "$dest"
  done
}

apply_dotfiles() {
  log "Applying dotfiles (mode=$DOT_MODE)"
  for d in "${DOT_DIRS[@]}"; do
    local src_dir="$ROOT_DIR/$d"
    if [ ! -d "$src_dir" ]; then
      warn "dot dir not found, skip: $src_dir"
      continue
    fi

    while IFS= read -r -d '' f; do
      local base dest
      base="$(basename "$f")"
      dest="$HOME/$base"

      if [[ "$base" == "." || "$base" == ".." ]]; then
        continue
      fi

      if [ "$DOT_MODE" = "copy" ]; then
        log "copy $base -> ~/"
        cp -f "$f" "$dest"
      else
        log "link $base -> ~/"
        ln -sf "$f" "$dest"
      fi
    done < <(find "$src_dir" -maxdepth 1 -type f -name ".*" -print0)
  done
}

set_default_shell_zsh() {
  local zsh_path
  zsh_path="$(command -v zsh || true)"
  if [ -z "$zsh_path" ]; then
    warn "zsh not found; skip chsh"
    return 0
  fi

  if [ "${SHELL:-}" != "$zsh_path" ]; then
    log "Changing default shell to zsh"
    chsh -s "$zsh_path"
  else
    warn "Default shell already zsh"
  fi
}

# -----------------------------
# Run
# -----------------------------
install_apt_packages
install_oh_my_zsh
install_zsh_plugins
apply_dotfiles
set_default_shell_zsh

log "Done. 새 터미널을 열거나 'exec zsh'로 적용하세요."
