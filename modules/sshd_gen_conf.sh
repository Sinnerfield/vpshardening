#!/usr/bin/bash
set -euo pipefail

DIR_SSHD_BACK="/etc/ssh/sshd_config.bak"

DIR_SSHD="/etc/ssh/sshd_config"
CUSTOM_DIR_FILE="/etc/ssh/sshd_config.d/99-customscript-ssh.conf"

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

make_sshd() {

  local INPUT_PORT="$1"

  #IF -p empty and script has not been run before:
  if [[ -z "$INPUT_PORT" && ! -e "$CUSTOM_DIR_FILE" ]]; then
    echo "SSHD warning: -p is not specified, defaulting to 22..."
    cat <<EOF | sudo tee "$CUSTOM_DIR_FILE" >/dev/null
PermitRootLogin no
PasswordAuthentication no
PermitEmptyPasswords no
Port 22
EOF
  fi
  #IF -p is not empty, we generally dont care if script has been run before or not, blatantly
  #overwrite entire file with new -p port, ufw func will consider rest for us
  #WARNING: IF script has been run before & no -p specified, NOTHING NEW WILL HAPPEN HERE!

  if [[ -n "$INPUT_PORT" ]]; then
    cat <<EOF | sudo tee "$CUSTOM_DIR_FILE" >/dev/null
PermitRootLogin no
PasswordAuthentication no
PermitEmptyPasswords no
Port ${INPUT_PORT}
EOF
  fi
  #now, test it!
  test_sshd
  return $?
}

make_sshd_old() { #has 1 Pos args

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
    #change to set port
    echo "Changing Default port to ${changeport}..."
    cat <<EOF | sudo tee -a "$DIR_SSHD" >/dev/null
Port ${changeport}
EOF
  fi

  # Now, test it!
  test_sshd
  return $?
}
