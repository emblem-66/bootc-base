#!/bin/bash
set -xeuo pipefail

# see what packages are installed on fedora-bootc image
rpm -qa | sort
# bulk remove of unwanted packages
rpm -qa 'qemu-user-static*' | xargs dnf remove -y
# see final packages on bootc-base image
rpm -qa | sort
