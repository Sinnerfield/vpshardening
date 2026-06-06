#!/usr/bin/bash
set -euo pipefail
IFS='
'

# vars zone ====================================

scriptname="deployer.sh"
PORT_INPUT="" #use as positional inside funct like $1
KEY_INPUT=""
RUN_HARDENING=false
RUN_VPS_SETUP=false
# vars zone ====================================
################################################
# Sources zone =================================

source ./modules/run_hardening.sh
# source ./modules/xray_installer.sh
# source ./modules/xray_configurator.sh#

# Sources zone =================================

help_print() {
  cat <<EOF
Usage: ${scriptname}.sh [-h] [-v] [-p] [-k]

  [-h]:   run vps hardening
  [-v]:   set up run_vpn
  [-p]:   custom port for ssh
  [-k]:   specify pub key for VPS
EOF

  exit 2
}

#parse -- args (if any)

while [ $# -gt 0 ]; do
  case "$1" in
  --help) help_print ;;
  -*) break ;;
  *) break ;;
  esac
done

#parse - args

while getopts ":hvp:k:" opt; do
  case ${opt} in
  h) RUN_HARDENING=true ;;
  v) RUN_VPS_SETUP=true ;;
  p) PORT_INPUT=$OPTARG ;;
  k) KEY_INPUT=$OPTARG ;;
  \?) help_print ;;
  esac
done
shift "$((OPTIND - 1))"

if [[ "$RUN_HARDENING" == true ]]; then
  run_hardening "$PORT_INPUT" "$KEY_INPUT"
fi

if [[ "$RUN_VPS_SETUP" == true ]]; then
  run_vps_setup
fi
