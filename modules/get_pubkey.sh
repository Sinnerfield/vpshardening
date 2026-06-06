#!/usr/bin/bash
set -euo pipefail

set -x

local KEY_INPUT="$1"

# VARS
SSH_DIR="$HOME/.ssh"
AUTH_FILE="${SSH_DIR}/authorized_keys"
#
#
#

install_pub_key() {
  #check if user proveded key
  if [[ -z ${KEY_INPUT} ]]; then
    echo "WARNING: NO PUBLIC KEY PROVIDED! ENSURE YOU HAVE OUT OF BAND ACCES OR YOULL BE LOCKED OUT ON RELOAD!!!"
  fi

  mkdir -p "$SSH_DIR"
  chmod 700 "$SSH_DIR"

  touch "$AUTH_FILE"
  chmod 600 "$AUTH_FILE"

  if ! grep -qF "$KEY_INPUT" "$AUTH_FILE"; then
    echo "$KEY_INPUT" >>"$AUTH_FILE"
    echo "SSH key installed successfully"
  else
    echo "SSH key already installed"
  fi
}
