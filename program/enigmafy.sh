########################################
# Enigmafy                             #
# By cibero42                          #
# https://github.com/cibero42/enigmafy #
# MIT License                          #
########################################
#!/bin/bash

# Help function
usage() {
  echo "Usage: enigmafy [-h] [-d gpg_key_file] [-e key_identity] [-s path/to/ssh/key]  <directory_or_archive>"
  echo
  echo "Options:"
  echo "-d: Specifies that the script should decrypt"
  echo "-e: Specifies that the script should encrypt"
  echo "-h: Shows this help message"
  echo "-r: Remove encrypted files after upload"
  echo "-s: Create hash and sign"
}

# Hello banner
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
privkey=""
decrypt=false
sign=false
sign_path=""

while getopts "d:e:hs:" opt; do
  case $opt in
    d)
      decrypt=true
      privkey=$OPTARG
      ;;
    e)
      pubkey=$OPTARG
      ;;
    h)
      usage
      exit 0
      ;;
    s)
      sign=true
      sign_path=$OPTARG
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

shift $((OPTIND-1))
archive=$1

if $decrypt; then
  total_steps=1
  step=1

  if $sign; then
    total_steps=$((total_steps + 2))
  fi


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

  if [ ! -e "$privkey" ]; then
    echo "The specified private key '$privkey' does not exist."
    exit 1
  fi

  if $sign; then
    printf "\n[$step/$total_steps] Verifying signature..."
    if cat ${archive%.age}.sha512 | ssh-keygen -q -Y check-novalidate -f $sign_path -n file -s ${archive%.age}.sha512.sig; then
      printf " OK"
      step=$((step + 1))
    else
      printf "\033[31mFAILED\033[0m"
      printf "\nUnable to verify signature. Exiting.\n"
      exit 1
    fi
    printf "\n[$step/$total_steps] Verifying hash..."
    if sha512sum --check --quiet ${archive%.age}.sha512; then
      printf " OK\n"
      step=$((step + 1))
    else
      printf "\033[31mFAILED\033[0m"
      printf "\nUnable to verify hash. Exiting.\n"
      exit 1
    fi
  fi

  echo "[$step/$total_steps] Decrypting..."
  age -d -i $privkey $archive | tar -xz
  echo " OK"

  printf "\n\nBye!"
  exit 0

else
  total_steps=1
  step=1
  if $sign; then
    total_steps=$((total_steps + 2))
  fi
  if [ "$s3_path" != "" ]; then
    total_steps=$((total_steps + 1))
  fi
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

  if [ ! -e "$pubkey" ]; then
    echo "The specified public key '$pubkey' does not exist."
    exit 1
  fi

  printf "\n[$step/$total_steps] Encrypting data..."
  tar -czf - $archive | age --recipients-file $pubkey -o ${archive}.age
  step=$((step + 1))
  printf " OK"

  if $sign; then
    printf "\n[$step/$total_steps] Generating Hash..."
    sha512sum ${archive}.age > ${archive}.sha512
    step=$((step + 1))
    printf " OK"

    printf "\n[3/$total_steps] Signing..."
    ssh-keygen -Y sign -f $sign_path -n file ${archive}.sha512
    step=$((step + 1))
    printf " OK"
  fi

  printf "\n\nBye!"
  exit 0
fi