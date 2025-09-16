#!/bin/sh

# Mounts the OpenBSD server's filesystem to the Mac and optionally prompts to SSH into the server.

OPENBSD_IP="46.23.95.45"
OPENBSD_USER="dev"
OPENBSD_REMOTE_DIR="/home/$OPENBSD_USER"
MACOS_MOUNTPOINT="/Users/admin/Desktop/openbsd.amsterdam"

alias su="sudo su"
alias ams="ssh $OPENBSD_USER@$OPENBSD_IP"
alias ams-f="sftp $OPENBSD_USER@$OPENBSD_IP"
alias ams-u="umount $MACOS_MOUNTPOINT"

# Check if sshfs is installed, if not, install via MacPorts
check_sshfs() {
  if ! command -v sshfs &> /dev/null; then
    echo "sshfs is not installed. Installing with MacPorts..."
    sudo port install sshfs
  fi
}

# Mount the OpenBSD filesystem regardless
check_sshfs
sshfs $OPENBSD_USER@$OPENBSD_IP:$OPENBSD_REMOTE_DIR $MACOS_MOUNTPOINT

# SSH prompt (optional)
ssh_openbsd_prompt() {
  echo "SSH as '$OPENBSD_USER' to openbsd.amsterdam? (Y/n)"
  read -r answer
  if [[ "$answer" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    ssh $OPENBSD_USER@$OPENBSD_IP
  fi
}
ssh_openbsd_prompt
