#!/bin/bash

# Help function
usage() {
  echo "Usage: enigmafy [-d gpg_key_file] [-e key_identity] [-h] [-k key_size] <directory_or_archive>"
  echo
  echo "Options:"
  echo "-d: Specifies that the script should decrypt"
  echo "-e: Specifies that the script should encrypt"
  echo "-h: Shows this help message"
  echo "-k: Set AES key size (default: 64)"
}

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

pubkey=""
aes_key=""
aes_size=64
decrypt=false

while getopts "hk:d:e:" opt; do
  case $opt in
    d)
      decrypt=true
      aes_key=$OPTARG
      ;;
    e)
      pubkey=$OPTARG
      ;;
    h)
      usage
      exit 0
      ;;
    k)
      aes_size=$OPTARG
      ;;
    *)
      echo "Invalid option: $OPTARG"
      usage
      exit 1
      ;;
    esac
done

# Check for the required positional arguments
if [ $# -lt 1 ]; then
  echo "Error: Missing required arguments."
  usage
  exit 1
fi

archive=${@: -1}

if $decrypt; then
  steps="4"
  hello
  if [ $# -lt 1 ]; then
    echo "Error: Unexpected arguments after the archive name."
    usage
    exit 1
  fi

  if [ ! -e "$archive" ]; then
    echo "The specified archive or directory '$archive' does not exist."
    exit 1
  fi

  printf "\n[1/$steps] Checking integrity..."
  # password=$(gpg --decrypt --quiet $aes_key)
  ek_file=$(gpg --decrypt --quiet $aes_key)
  password=$(grep 'password:' <<< "$ek_file" | awk '{print $2}')
  original_hash=$(grep 'hash:' <<< "$ek_file" | awk '{print $2}')
  calculated_hash=$(sha512sum $archive | awk '{print $1}')
  if [ "$original_hash" != "$calculated_hash" ]; then
    printf "\033[31mFAILED\033[0m"
    printf "\n\033[1;31mHashes do not match. Aborting!\033[0m"
    exit 1
  fi
  printf " OK"

  printf "\n[2/$steps] Decrypting..."
  openssl enc -d -aes-256-cbc -pbkdf2 -iter 50000 -in $archive -out "${archive%.eea}.ec" -k $password
  printf " OK"

  printf "\n[3/$steps] Uncompressing..."
  tar -xf "${archive%.eea}.ec"
  printf " OK"

  printf "\n[$steps/$steps] Cleaning..."
  rm "${archive%.eea}.ec"
  printf " OK"
  printf "\n\nBye!"
  exit 0

else
  steps="5"
  hello

  if [ $# -lt 1 ]; then
    echo "Error: Unexpected arguments after the archive name."
    usage
    exit 1
  fi

  if [ ! -e "$archive" ]; then
    echo "The specified archive or directory '$archive' does not exist."
    exit 1
  fi

  printf "\n[1/$steps] Compressing..."
  tar -czf "${archive}.ec" "$archive"
  printf " OK"

  printf "\n[2/$steps] Generating symetrical password..."
  password=$(pwgen -s $aes_size -c -n -y -1)
  printf " OK"

  printf "\n[3/$steps] Encrypting data..."
  openssl enc -aes-256-cbc -pbkdf2 -iter 50000 -in "${archive}.ec" -out "${archive}.eea" -k $password
  printf " OK"

  printf "\n[4/$steps] Calculating SHA512 of encrypted archive..."
  hash=$(sha512sum "${archive}.eea" | awk '{print $1}')
  gpg --encrypt --recipient $pubkey --output "$archive.ek" <<EOF
password: $password
hash: $hash
EOF
  printf " OK"

  printf "\n[$steps/$steps] Cleaning..."
  rm $archive.ec
  printf " OK"
  printf "\n\nBye!"
  exit 0
fi