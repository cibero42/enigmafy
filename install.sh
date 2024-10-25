#!/bin/bash

hello() {
  printf "▓█████  ███▄    █  ██▓  ▄████  ███▄ ▄███▓ ▄▄▄        █████▒▓██   ██▓
▓█   ▀  ██ ▀█   █ ▓██▒ ██▒ ▀█▒▓██▒▀█▀ ██▒▒████▄    ▓██   ▒  ▒██  ██▒
▒███   ▓██  ▀█ ██▒▒██▒▒██░▄▄▄░▓██    ▓██░▒██  ▀█▄  ▒████ ░   ▒██ ██░
▒▓█  ▄ ▓██▒  ▐▌██▒░██░░▓█  ██▓▒██    ▒██ ░██▄▄▄▄██ ░▓█▒  ░   ░ ▐██▓░
░▒████▒▒██░   ▓██░░██░░▒▓███▀▒▒██▒   ░██▒ ▓█   ▓██▒░▒█░      ░ ██▒▓░
░░ ▒░ ░░ ▒░   ▒ ▒ ░▓   ░▒   ▒ ░ ▒░   ░  ░ ▒▒   ▓▒█░ ▒ ░       ██▒▒▒ 
 ░ ░  ░░ ░░   ░ ▒░ ▒ ░  ░   ░ ░  ░      ░  ▒   ▒▒ ░ ░       ▓██ ░▒░ 
   ░      ░   ░ ░  ▒ ░░ ░   ░ ░      ░     ░   ▒    ░ ░     ▒ ▒ ░░  
   ░  ░         ░  ░        ░        ░         ░  ░         ░ ░     
                                                            ░ ░     "
  printf "\nDeveloped by cibero42"
  printf "\nhttps://github.com/cibero42/enigmafy"
  printf "\nMIT License\n\n"
}

if [ "$(id -u)" != 0 ]; then
    echo "This script requires root priviledges. Please run it with sudo!"
fi

hello

printf "\nThis script will install Enigmafy and dependencies on your computer.\n"
read -p "Proceed? [Y/n] " choice

if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
    echo "Installation aborted by user."
    exit 0
fi

printf "\n[1/3] Installing dependencies...\n"
# PKG installable dependencies
if command -v yum > /dev/null 2>&1; then
    dnf -q -y install age gnupg unzip tar curl which rclone
elif command -v apt > /dev/null 2>&1; then
    apt -qq update
    apt -qq -y install age gnupg unzip tar curl which rclone
else
    echo "No supported package manager found."
    exit 1
fi

printf "\nDependencies installed"

printf "\n[2/3] Installing the script..."
cp program/enigmafy.sh /usr/local/bin/enigmafy
chmod +x /usr/local/bin/enigmafy
printf " OK"

printf "\n[3/3] Verifying installation..."
if which enigmafy > /dev/null 2>&1; then
    printf " OK\n"
    echo "Enigmafy was successfully installed"
else
    printf " FAILED"
    echo "The installation didn't succeed. Try rerunning the script."
fi