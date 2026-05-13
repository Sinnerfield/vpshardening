#!/usr/bin/bash
set -euo pipefail

set -x

#vars zone

DIR_SSHD="/etc/ssh/sshd_config"
DIR_SSHD_BACK="/etc/ssh/sshd_config.bak"

#sources zone
source ./os_release.sh

check_ssh() {
  PACKAGE="openssh-server"

  if dpkg -l "$PACKAGE" &>/dev/null; then
    return 0
  else

    echo "SSH service is not installed, installing..."
    sudo apt-get update && sudo apt-get install -y "$PACKAGE"

  fi

  return 0
}

ssh_makecfg() {

  if [[ -e "$DIR_SSHD" ]]; then #if sshd conf exists, create backup

    sudo cp "$DIR_SSHD" "${DIR_SSHD_BACK}_$(date +%F)"
    echo "Created backup for sshd_config"
  else
    echo "Error: sshd_config not found. Cannot create backup." >&2
    return 1
  fi
  return 0
}

check_and_make_ssh() {
  checkssh
  ssh_makecfg

  return 0
}

# TODO:
# 1) modify sshd_config
# 1.1) Generate keys or ask user to generate them
# 2) configure UFW or iptables(latter better)
# 3) Install & configure fail2ban
