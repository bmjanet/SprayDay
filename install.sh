#!/bin/bash
# SprayDay installer
# Sets up an isolated Python venv (so InquirerPy is installed without touching
# the system Python — avoids Kali's PEP-668 "externally-managed-environment"
# error) and drops a launcher on PATH so `sprayday` works from anywhere.

set -euo pipefail

INSTALL_DIR="/opt/sprayday"
VENV_DIR="${INSTALL_DIR}/venv"
LAUNCHER="/usr/local/bin/sprayday"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

red()   { printf '\033[91m[-]\033[0m %s\n' "$1"; }
green() { printf '\033[92m[+]\033[0m %s\n' "$1"; }
info()  { printf '\033[94m[*]\033[0m %s\n' "$1"; }

# Must be root to write to /opt and /usr/local/bin.
if [ "$(id -u)" -ne 0 ]; then
    red "Please run as root:  sudo ./install.sh"
    exit 1
fi

if [ ! -f "${SRC_DIR}/sprayday" ]; then
    red "sprayday script not found next to install.sh"
    exit 1
fi

# Need python3 + venv module.
if ! command -v python3 >/dev/null 2>&1; then
    red "python3 not found. Install it first."
    exit 1
fi

info "Creating install directory: ${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}"

info "Copying sprayday to ${INSTALL_DIR}"
install -m 0755 "${SRC_DIR}/sprayday" "${INSTALL_DIR}/sprayday"

info "Creating virtual environment: ${VENV_DIR}"
if ! python3 -m venv "${VENV_DIR}" 2>/dev/null; then
    red "Failed to create venv. Install the venv module:"
    red "  sudo apt install -y python3-venv"
    exit 1
fi

info "Installing InquirerPy into the venv"
"${VENV_DIR}/bin/pip" install --quiet --upgrade pip >/dev/null 2>&1 || true
"${VENV_DIR}/bin/pip" install --quiet InquirerPy

info "Writing launcher: ${LAUNCHER}"
cat > "${LAUNCHER}" <<EOF
#!/bin/bash
# SprayDay launcher — runs the tool inside its isolated venv.
exec "${VENV_DIR}/bin/python3" "${INSTALL_DIR}/sprayday" "\$@"
EOF
chmod 0755 "${LAUNCHER}"

green "SprayDay installed."
info  "Try it:  sprayday --help"
info  "Example: sprayday 10.10.10.10 --default"
echo
info  "Backend tools it relies on (installed by default on Kali):"
info  "  NetExec (nxc), mysql client, psql client"
info  "To uninstall:  sudo rm -rf ${INSTALL_DIR} ${LAUNCHER}"
