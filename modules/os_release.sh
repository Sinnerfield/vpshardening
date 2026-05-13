#!/usr/bin/bash
while IFS= read -r line; do

  if [[ "$line" == NAME=* ]]; then

    os_name="${line#*=}"
    os_name="${os_name//\"/}"
    break
  fi
done <"/etc/os-release"
