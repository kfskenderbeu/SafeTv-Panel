# SafeTV Panel

Installer for the SafeTV IPTV panel. This repository contains **only the installer**; the compiled programs are published in
[Releases](../../releases). Every new install runs a **7-day trial**; then it needs an official licence (Hardware ID based): open **License** in the panel.

```bash
curl -fsSL https://raw.githubusercontent.com/kfskenderbeu/SafeTv-Panel/main/install.sh | sudo bash -s -- --public-host YOUR.IP.OR.DOMAIN
```

Install on another server over SSH: `./install.sh --remote root@HOST --public-host HOST`.
Linux x86_64, systemd; installs MariaDB, creates the database, the settings and the service, and prints the panel address, admin password and Hardware ID.
Re-running upgrades the programs and keeps settings, data, database and licence.
