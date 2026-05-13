#!/usr/bin/bash
set -euo pipefail
IFS='
'

# vars zone ====================================

scriptname="deployer.sh"
PORT_INPUT="" #use as positional inside funct like $1
# vars zone ====================================
################################################
# Sources zone =================================

# source ./modules/run_hardening.sh
# source ./modules/xray_installer.sh
# source ./modules/xray_configurator.sh#

# Sources zone =================================

help_print() {
  cat <<EOF
Usage: ${scriptname}.sh [-h] [-v] [-p]

  [-h]:   run vps hardening
  [-v]:   set up run_vpn
  [-p]:   custom port for ssh
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

while getopts ":hvp:" opt; do
  case ${opt} in
  h) run_hardening ;;
  v) run_vpn_setup ;;
  p) PORT_INPUT=$OPTARG ;;
  \?) help_print ;;
  esac
done
shift "$((OPTIND - 1))"
