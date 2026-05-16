#!/usr/bin/bash
set -euo pipefail

set -x

#vars zone

DIR_SSHD="/etc/ssh/sshd_config"
DIR_SSHD_BACK="/etc/ssh/sshd_config.bak"
#sources zone
source ./os_release.sh
source ./sshd_gen_conf.sh

check_ufw() {
  PACKAGE="ufw"

  if dpkg -l "$PACKAGE" &>/dev/null; then
    return 0
  else
    echo "UFW firewall is not installed, installing..."
    sudo apt-get update && sudo apt-get install -y "$PACKAGE"
    sudo systemctl enable --now ufw
  fi

}

make_ufw() {
  sudo ufw allow ssh
  sudo ufw --force enable

}

check_ssh() {
  PACKAGE="openssh-server"

  if dpkg -l "$PACKAGE" &>/dev/null; then
    return 0
  else

    echo "SSH service is not installed, installing..."
    sudo apt-get update && sudo apt-get install -y "$PACKAGE"
    sudo systemctl enable --now sshd

  fi

  return 0
}

ssh_make_back_cfg() {

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
  local PORT_INPUT="$1"
  check_ssh
  ssh_make_back_cfg
  make_sshd "$PORT_INPUT"
  return 0
}

check_and_make_ufw() {
  check_ufw
  make_ufw
}

# TODO:
# 1) edit sshd [DONE!]
# 1.11) test with sshd -t and reload systemctl [DONE!]
# 1.1) Generate keys or ask user to generate them
# 2) configure UFW or iptables(latter better) [50%]
# 3) Install & configure fail2ban
# NOTE: ALWAYS RUN UFW FUNCT BEFORE ANYTHING IN sshd_gen_conf as im lazy to implement checks, latter sh
# assumes ufw is installed already

# NOTE: please do not use this funct as for now
generate_keys() {

  echo "Generating ssh keys, do you want to specify custom location?" # add custom location later
  ssh-keygen -t ed25519
}

#WARNING: master funct!

run_hardening() {
  local PORT_INPUT="$1"
  check_and_make_ufw
  check_and_make_ssh "$PORT_INPUT"
}
