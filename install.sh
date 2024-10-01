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
    dnf -q -y install openssl gnupg pwgen unzip tar curl which
elif command -v apt > /dev/null 2>&1; then
    apt -qq update
    apt -qq -y install openssl gnupg pwgen unzip tar curl which
else
    echo "No supported package manager found."
    exit 1
fi

# AWS CLI
if which aws > /dev/null 2>&1; then
    printf "\n\nAWS CLI already exists. Skipping..."
else
    printf "\nAre you using the S3 feature? AWS CLI will be installed! [Y/n] "
    read choice

    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
        printf "\nSkipping AWS CLI installation."
    else
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        cat << EOF > "aws.key"
-----BEGIN PGP PUBLIC KEY BLOCK-----
mQINBF2Cr7UBEADJZHcgusOJl7ENSyumXh85z0TRV0xJorM2B/JL0kHOyigQluUG
ZMLhENaG0bYatdrKP+3H91lvK050pXwnO/R7fB/FSTouki4ciIx5OuLlnJZIxSzx
PqGl0mkxImLNbGWoi6Lto0LYxqHN2iQtzlwTVmq9733zd3XfcXrZ3+LblHAgEt5G
TfNxEKJ8soPLyWmwDH6HWCnjZ/aIQRBTIQ05uVeEoYxSh6wOai7ss/KveoSNBbYz
gbdzoqI2Y8cgH2nbfgp3DSasaLZEdCSsIsK1u05CinE7k2qZ7KgKAUIcT/cR/grk
C6VwsnDU0OUCideXcQ8WeHutqvgZH1JgKDbznoIzeQHJD238GEu+eKhRHcz8/jeG
94zkcgJOz3KbZGYMiTh277Fvj9zzvZsbMBCedV1BTg3TqgvdX4bdkhf5cH+7NtWO
lrFj6UwAsGukBTAOxC0l/dnSmZhJ7Z1KmEWilro/gOrjtOxqRQutlIqG22TaqoPG
fYVN+en3Zwbt97kcgZDwqbuykNt64oZWc4XKCa3mprEGC3IbJTBFqglXmZ7l9ywG
EEUJYOlb2XrSuPWml39beWdKM8kzr1OjnlOm6+lpTRCBfo0wa9F8YZRhHPAkwKkX
XDeOGpWRj4ohOx0d2GWkyV5xyN14p2tQOCdOODmz80yUTgRpPVQUtOEhXQARAQAB
tCFBV1MgQ0xJIFRlYW0gPGF3cy1jbGlAYW1hem9uLmNvbT6JAlQEEwEIAD4CGwMF
CwkIBwIGFQoJCAsCBBYCAwECHgECF4AWIQT7Xbd/1cEYuAURraimMQrMRnJHXAUC
ZqFYbwUJCv/cOgAKCRCmMQrMRnJHXKYuEAC+wtZ611qQtOl0t5spM9SWZuszbcyA
0xBAJq2pncnp6wdCOkuAPu4/R3UCIoD2C49MkLj9Y0Yvue8CCF6OIJ8L+fKBv2DI
yWZGmHL0p9wa/X8NCKQrKxK1gq5PuCzi3f3SqwfbZuZGeK/ubnmtttWXpUtuU/Iz
VR0u/0sAy3j4uTGKh2cX7XnZbSqgJhUk9H324mIJiSwzvw1Ker6xtH/LwdBeJCck
bVBdh3LZis4zuD4IZeBO1vRvjot3Oq4xadUv5RSPATg7T1kivrtLCnwvqc6L4LnF
0OkNysk94L3LQSHyQW2kQS1cVwr+yGUSiSp+VvMbAobAapmMJWP6e/dKyAUGIX6+
2waLdbBs2U7MXznx/2ayCLPH7qCY9cenbdj5JhG9ibVvFWqqhSo22B/URQE/CMrG
+3xXwtHEBoMyWEATr1tWwn2yyQGbkUGANneSDFiTFeoQvKNyyCFTFO1F2XKCcuDs
19nj34PE2TJilTG2QRlMr4D0NgwLLAMg2Los1CK6nXWnImYHKuaKS9LVaCoC8vu7
IRBik1NX6SjrQnftk0M9dY+s0ZbAN1gbdjZ8H3qlbl/4TxMdr87m8LP4FZIIo261
Eycv34pVkCePZiP+dgamEiQJ7IL4ZArio9mv6HbDGV6mLY45+l6/0EzCwkI5IyIf
BfWC9s/USgxchg==
=ptgS
-----END PGP PUBLIC KEY BLOCK-----
EOF
        gpg --import aws.key
        curl -o awscliv2.sig https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip.sig
        if gpg --verify awscliv2.sig awscliv2.zip; then
            unzip awscliv2.zip
            ./aws/install
            rm awscliv2.zip aws.key awscliv2.sig
        else
            echo "Signature verification failed. Aborting."
            rm awscliv2.zip aws.key awscliv2.sig
            exit 1
        fi
    fi
fi

printf "\nDependencies installed"

printf "\n[2/3] Installing the script..."
mv program/enigmafy.sh /usr/local/bin/enigmafy
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