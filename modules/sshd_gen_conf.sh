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

harden_sshd_config() {

  local changeport="$1"
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
    sudo ufw allow ${changeport}/tcp
    sudo ufw reload
    echo "Changing Default port to ${changeport}..."
    cat <<EOF >>$DIR_SSHD_BACK
Port ${changeport}
EOF
  fi
}
