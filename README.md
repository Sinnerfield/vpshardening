
# The Stealth Deployer: Automated VPS Hardening

An idempotent, modular Bash script designed to automate Linux server setup, secure SSH access, and configure firewall rules dynamically. Built with a focus on preventing remote lockouts during automated deployments.

## Core Features (MVP)

* **Automated SSH Hardening:** Dynamically generates drop-in configurations (`/etc/ssh/sshd_config.d/`) to disable Root login, disable Password Authentication, and enforce empty password denial.


* **Pre-Flight Safety Checks:** Automatically tests SSH daemon configurations (`sshd -t`) for syntax errors before reloading systemctl, preventing accidental remote lockouts. It also automatically creates timestamped backups of the original `sshd_config`.


* **Dynamic Firewall Configuration:** Installs and enables UFW. Automatically denies the default port 22 and whitelists custom user-defined SSH ports dynamically via drop-in UFW app profiles.


* **Public Key Management:** Injects user-provided SSH public keys directly into `~/.ssh/authorized_keys`, securely managing directory (700) and file (600) permissions.


* **Strict Error Handling:** Built with `set -euo pipefail` across all modules to ensure the script fails securely on undocumented errors or unbound variables rather than executing partially.



## Usage

The script is executed via command-line flags to allow flexible deployment:

```bash
./deployer.sh -h -p <CUSTOM_PORT> -k "<YOUR_PUBLIC_KEY>"

```

* `-h`: Execute VPS hardening modules.


* `-p`: Define a custom SSH port.


* `-k`: Supply the SSH public key for remote access.(not tested!)



## Roadmap

* Implementation of automated `fail2ban` installation and configuration.


* Migration from UFW to direct `iptables` rules for lower-level network control.


* Automated proxy setup and routing (Xray/VPN deployment).


