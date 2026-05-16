#!/usr/bin/bash
set -euo pipefail

DIR_SSHD_BACK="/etc/ssh/sshd_config.bak"

latestbackup() {
  BACKUP_FILES=("${DIR_SSHD_BACK}"_*) #array

  LATEST_BACKUP="${BACKUP_FILES[-1]}"

  if [[! -f "$LATEST_BACKUP" ]]; then
    echo "Error: No backups found." >&2
    exit 1
  fi

}

make_sshd() { #has 1 Pos args

  local changeport="$PORT_INPUT"
  local settimeout="$2"

  cat <<EOF >>$DIR_SSHD_BACK
PermitRootLogin no
PasswordAuthentication no
PermitEmptyPasswords no
EOF

  if [[ changeport == "" ]]; then
    echo "-p argument not specified. Default port for ssh set to 22..."
    cat <<EOF >>$DIR_SSHD_BACK
Port 22
EOF
  else
    #change to set port & disable regular 22
    sudo ufw allow ${changeport}/tcp

    sudo ufw deny 22/tcp
    sudo ufw reload

    echo "Changing Default port to ${changeport}..."
    cat <<EOF >>$DIR_SSHD_BACK
Port ${changeport}
EOF
  fi

  # Now, test it!
  if test_sshd; then
    return 0
    echo "Sshd passed test!"
  else
    return 1
  fi
}

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
