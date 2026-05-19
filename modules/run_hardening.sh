#!/usr/bin/bash
set -euo pipefail

set -x

#vars zone

DIR_SSHD="/etc/ssh/sshd_config"
DIR_SSHD_BACK="/etc/ssh/sshd_config.bak"
#sources zone
source ./modules/os_release.sh
source ./modules/sshd_gen_conf.sh

check_ufw() {
  PACKAGE="ufw"

  if [[ -x /usr/sbin/ufw ]]; then
    return 0
  else
    echo "UFW firewall is not installed, installing..."
    sudo apt-get update && sudo apt-get install -y "$PACKAGE"
    sudo systemctl enable --now ufw
  fi

}
make_ufw() {
  local PORT_INPUT="$1"
  # checks for previous possible script runs:
  #
  if [[ -z "$PORT_INPUT" && -e /etc/ufw/applications.d/custom_ssh_port ]]; then
    echo "UFW WARNING: Script has been run before, no -p supplied, your custom port is the same as before(if any), check [sudo ufw status] for more info"
    return 0
  fi
  #WARNING: script has not been run before, -p scpecified, block default 22

  if [[ -n "$PORT_INPUT" && ! -e /etc/ufw/applications.d/custom_ssh_port ]]; then
    echo "UFW Warning: denying standart port 22 as custom -p${PORT_INPUT} has been specified "
    sudo ufw deny 22/tcp

  else
    # script has not been run before, no custom port -p, set port to default 22
    if [[ -z "$PORT_INPUT" ]]; then
      echo "UFW Warning: no custom -p specified, defaulting to 22..."
      PORT_INPUT="22"
    fi
  fi
  #decided to just overwrite this even if exits, means we run script before, so we just
  #overwrite it with new -p if any
  cat <<EOF | sudo tee /etc/ufw/applications.d/custom_ssh_port >/dev/null
[Custom_ssh_port_${PORT_INPUT}]
title=Custom_ssh
description=Custom SSH PORT by vpshardening script
ports=${PORT_INPUT}/tcp
EOF

  #now apply to ufw
  sudo ufw app update all
  # check if app updated
  if [[ -z $(sudo ufw app list | grep -i custom) ]]; then
    echo "Error: cannot find custom ufw app"
    return 1
  else
    sudo ufw allow Custom_ssh_port
    sudo ufw --force enable
    sudo ufw reload
  fi

}

make_ufw_old() {
  sudo ufw allow ssh
  sudo ufw --force enable

}

check_ssh() {
  PACKAGE="openssh-server"
  BINARY="sshd"

  if command -v "$BINARY" &>/dev/null; then
    return 0
  else

    echo "SSH service is not installed, installing..."
    sudo apt-get update && sudo apt-get install -y "$PACKAGE"
    sudo systemctl enable --now ssh

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
  local PORT_INPUT="$1"
  check_ufw
  make_ufw "$PORT_INPUT"
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
  check_and_make_ufw "$PORT_INPUT"
  check_and_make_ssh "$PORT_INPUT"
}
