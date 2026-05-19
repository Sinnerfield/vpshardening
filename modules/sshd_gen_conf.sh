#!/usr/bin/bash
set -euo pipefail

DIR_SSHD_BACK="/etc/ssh/sshd_config.bak"

DIR_SSHD="/etc/ssh/sshd_config"

test_sshd() {

  if sudo sshd -t &>/dev/null; then
    echo "Sshd config [done!], no errors detected."
    sudo systemctl reload sshd
    return 0
  else
    echo "Error: sshd errors detected!"
    sudo sshd -t
    return 1
  fi
}

latestbackup() {
  BACKUP_FILES=("${DIR_SSHD_BACK}"_*) #array

  LATEST_BACKUP="${BACKUP_FILES[-1]}"

  if [[ ! -f "$LATEST_BACKUP" ]]; then
    echo "Error: No backups found." >&2
    exit 1
  fi

}

make_sshd() { #has 1 Pos args

  local changeport="$1"

  cat <<EOF | sudo tee -a "$DIR_SSHD" >/dev/null
PermitRootLogin no
PasswordAuthentication no
PermitEmptyPasswords no
EOF

  if [[ -z "$changeport" ]]; then
    echo "-p argument not specified. Default port for ssh set to 22..."
    cat <<EOF | sudo tee -a "$DIR_SSHD" >/dev/null
Port 22
EOF
  else
    #change to set port & disable regular 22
    sudo ufw allow ${changeport}/tcp

    sudo ufw deny 22/tcp
    sudo ufw reload

    echo "Changing Default port to ${changeport}..."
    cat <<EOF | sudo tee -a "$DIR_SSHD" >/dev/null
Port ${changeport}
EOF
  fi

  # Now, test it!
  test_sshd
  return $?
}
