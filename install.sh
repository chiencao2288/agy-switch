#!/usr/bin/env bash
# ==============================================================================
# agy-switch Installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/chiencao2288/agy-switch/main/install.sh | bash
#
# Custom install location:
#   curl -fsSL https://raw.githubusercontent.com/chiencao2288/agy-switch/main/install.sh | bash -s ~/.local/bin
#
# Environment variables:
#   AGY_SWITCH_INSTALL_DIR  Custom installation directory (default: ~/.local/bin)
#   AGY_SWITCH_OWNER        GitHub repository owner (default: chiencao2288)
#   AGY_SWITCH_REPO         GitHub repository name (default: agy-switch)
#   AGY_SWITCH_BRANCH       Git branch to pull from (default: main)
# ==============================================================================

set -euo pipefail

REPO_OWNER="${AGY_SWITCH_OWNER:-chiencao2288}"
REPO_NAME="${AGY_SWITCH_REPO:-agy-switch}"
BRANCH="${AGY_SWITCH_BRANCH:-main}"
DEFAULT_INSTALL_DIR="${HOME}/.local/bin"
TARGET_DIR="${1:-${AGY_SWITCH_INSTALL_DIR:-$DEFAULT_INSTALL_DIR}}"
TARGET_BIN="${TARGET_DIR}/agy-switch"
RAW_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/agy-switch"

# Color definitions
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_GREEN='\033[0;32m'
C_CYAN='\033[0;36m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'

info() {
    printf "${C_CYAN}ℹ %s${C_RESET}\n" "$*"
}

success() {
    printf "${C_GREEN}✔ %s${C_RESET}\n" "$*"
}

warn() {
    printf "${C_YELLOW}⚠ %s${C_RESET}\n" "$*"
}

error() {
    printf "${C_RED}✖ %s${C_RESET}\n" "$*" >&2
}

printf "\n${C_BOLD}🔄 agy-switch Installer${C_RESET}\n"
printf "──────────────────────────────────────────────────────\n"

# 1. Ensure target directory exists
mkdir -p "${TARGET_DIR}"

# 2. Acquire agy-switch binary
# If running inside a git clone where agy-switch exists locally, prefer local copy
SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
fi

if [[ -n "${SCRIPT_DIR}" && -f "${SCRIPT_DIR}/agy-switch" ]]; then
    info "Installing from local repository: ${SCRIPT_DIR}/agy-switch"
    cp -f "${SCRIPT_DIR}/agy-switch" "${TARGET_BIN}"
elif [[ -n "${SCRIPT_DIR}" && -f "${SCRIPT_DIR}/bin/agy-switch" ]]; then
    info "Installing from local repository: ${SCRIPT_DIR}/bin/agy-switch"
    cp -f "${SCRIPT_DIR}/bin/agy-switch" "${TARGET_BIN}"
else
    info "Downloading agy-switch from ${REPO_OWNER}/${REPO_NAME} (${BRANCH})..."
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "${RAW_URL}" -o "${TARGET_BIN}"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "${TARGET_BIN}" "${RAW_URL}"
    else
        error "Neither 'curl' nor 'wget' is available. Please install one of them."
        exit 1
    fi
fi

# 3. Validate script
if [[ ! -s "${TARGET_BIN}" ]]; then
    error "Installation failed: Downloaded file is empty."
    exit 1
fi

if ! head -n 1 "${TARGET_BIN}" | grep -qE '^#!/(usr/bin/env bash|bin/bash)'; then
    error "Installation failed: File does not appear to be a valid Bash script."
    exit 1
fi

chmod +x "${TARGET_BIN}"
success "Installed executable to: ${TARGET_BIN}"

# 4. PATH verification
path_configured=true
case ":${PATH}:" in
    *":${TARGET_DIR}:"*)
        ;;
    *)
        path_configured=false
        ;;
esac

if [[ "${path_configured}" == "false" ]]; then
    warn "The install directory '${TARGET_DIR}' is not in your PATH."
    printf "\nAdd it by appending this line to your shell configuration (~/.bashrc or ~/.zshrc):\n"
    printf "  export PATH=\"%s:\$PATH\"\n\n" "${TARGET_DIR}"
fi

# 5. Check dependencies
if ! command -v secret-tool >/dev/null 2>&1; then
    warn "'secret-tool' (libsecret) not found. Required for OS keyring token synchronization."
    warn "Install via your package manager (e.g. Fedora: sudo dnf install libsecret)."
fi

if ! command -v jq >/dev/null 2>&1; then
    warn "'jq' not found. Recommended for parsing email info (sudo dnf install jq)."
fi

printf "──────────────────────────────────────────────────────\n"
success "agy-switch is ready to use!"
printf "Run 'agy-switch --help' or 'agy-switch list' to get started.\n\n"
