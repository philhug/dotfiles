#!/bin/sh
set -e

BIN_DIR="${HOME}/.local/bin"
mkdir -p "${BIN_DIR}"
export PATH="${BIN_DIR}:${PATH}"

#
# 1. Install git + git-credential-oauth
#
install_git_credential_oauth() {
    REPO="hickford/git-credential-oauth"
    LATEST=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | sed 's/.*"v\(.*\)".*/\1/')
    ARCH=$(uname -m)
    case "${ARCH}" in
        x86_64) ARCH="amd64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        i386|i686) ARCH="386" ;;
        *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;;
    esac
    URL="https://github.com/${REPO}/releases/download/v${LATEST}/git-credential-oauth_${LATEST}_linux_${ARCH}.tar.gz"
    echo "Installing git-credential-oauth v${LATEST}..."
    curl -fsSL "${URL}" | tar -xz -C "${BIN_DIR}" git-credential-oauth
}

if command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm git
    install_git_credential_oauth
elif command -v apt >/dev/null 2>&1; then
    sudo apt update && sudo apt install -y git curl
    install_git_credential_oauth
elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y git curl
    install_git_credential_oauth
else
    echo "Unsupported package manager" >&2
    exit 1
fi

#
# 2. Configure git credential helpers
#
git config --global --unset-all credential.helper 2>/dev/null || true
git config --global credential.helper "cache --timeout 21600"
git config --global --add credential.helper "${BIN_DIR}/git-credential-oauth"

#
# 3. Install chezmoi
#
if ! command -v chezmoi >/dev/null 2>&1; then
    if command -v curl >/dev/null 2>&1; then
        sh -c "$(curl -fsSL https://git.io/chezmoi)" -- -b "${BIN_DIR}"
    elif command -v wget >/dev/null 2>&1; then
        sh -c "$(wget -qO- https://git.io/chezmoi)" -- -b "${BIN_DIR}"
    else
        echo "curl or wget required" >&2
        exit 1
    fi
fi

#
# 4. Init chezmoi from Forgejo (triggers OAuth2 browser flow)
#
chezmoi init --apply https://code.homenet.ge/hug/dotfiles.git
