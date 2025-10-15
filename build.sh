#!/bin/bash
set -xeuo pipefail

# see what packages are installed on fedora-bootc image
rpm -qa | sort
# bulk remove of unwanted packages
rpm -qa 'qemu-user-static*' | xargs dnf remove -y
# see final packages on bootc-base image
rpm -qa | sort



# repo - tailscale
curl --create-dirs -o /etc/yum.repos.d/_tailscale.repo https://pkgs.tailscale.com/stable/fedora/tailscale.repo

# justfile
curl --create-dirs -o /usr/share/just/justfile https://raw.githubusercontent.com/emblem-66/bootc-config/refs/heads/main/_usr_share_just_justfile

# systemd - bootc
curl --create-dirs -o /usr/lib/systemd/system/bootc-update.service https://raw.githubusercontent.com/emblem-66/bootc-config/refs/heads/main/_usr_lib_systemd_system_bootc-update.service
curl --create-dirs -o /usr/lib/systemd/system/bootc-update.timer https://raw.githubusercontent.com/emblem-66/bootc-config/refs/heads/main/_usr_lib_systemd_system_bootc-update.timer

# systemd - flatpak
curl --create-dirs -o /usr/lib/systemd/system/flatpak-setup.service https://raw.githubusercontent.com/emblem-66/bootc-config/refs/heads/main/_usr_lib_systemd_system_flatpak-setup.service
curl --create-dirs -o /usr/lib/systemd/system/flatpak-update.service https://raw.githubusercontent.com/emblem-66/bootc-config/refs/heads/main/_usr_lib_systemd_system_flatpak-update.service
curl --create-dirs -o /usr/lib/systemd/system/flatpak-update.timer https://raw.githubusercontent.com/emblem-66/bootc-config/refs/heads/main/_usr_lib_systemd_system_flatpak-update.timer
curl --create-dirs -o /usr/lib/systemd/system/flatpak-packages.service https://raw.githubusercontent.com/emblem-66/bootc-config/refs/heads/main/_usr_lib_systemd_system_flatpak-packages.service

# systemd - brew
curl --create-dirs -o /usr/lib/systemd/system/brew-setup.service https://raw.githubusercontent.com/emblem-66/bootc-config/refs/heads/main/_usr_lib_systemd_system_brew-setup.service
curl --create-dirs -o /usr/lib/systemd/system/brew-update.service https://raw.githubusercontent.com/emblem-66/bootc-config/refs/heads/main/_usr_lib_systemd_system_brew-update.service
curl --create-dirs -o /usr/lib/systemd/system/brew-packages.service https://raw.githubusercontent.com/emblem-66/bootc-config/refs/heads/main/_usr_lib_systemd_system_brew-packages.service

# Tailscale
dnf install -y tailscale #&& rm -rf /etc/yum.repos.d/tailscale.repo
# Just
dnf install -y just



# Cockpit
dnf install -y cockpit cockpit-podman
# piper
dnf install -y piper

# FTP
dnf install -y vsftpd
systemctl enable vsftpd
cat /etc/vsftpd/vsftpd.conf


### SystemD
# tailscale
systemctl enable tailscaled.service
systemctl enable sshd.service
# bootc
systemctl enable bootc-update.timer
# flatpak
systemctl enable flatpak-setup.service
systemctl enable flatpak-update.service
systemctl enable flatpak-update.timer
systemctl enable flatpak-packages.service
# brew
#systemctl enable brew-setup.service
#systemctl enable brew-update.service
#systemctl enable brew-packages.service
# mask
systemctl mask flatpak-add-fedora-repos.service
systemctl mask fedora-third-party-refresh.service
# failing systemd-remount-fs.service
systemctl mask systemd-remount-fs.service
# cockpit
systemctl enable cockpit.socket

# repo cleanup
rm -rf /etc/yum.repos.d/_*.repo

# tuned profiles
# https://www.redhat.com/en/blog/linux-tuned-tuning-profiles