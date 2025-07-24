package main

import (
	"flag"
	"fmt"
	"os"
)

// Global flags for command-line arguments
var (
	showHelp    bool
	showVersion bool
)

func version() {
	banner := `
▓█████  ███▄    █  ██▓  ▄████  ███▄ ▄███▓ ▄▄▄        █████▒▓██   ██▓
▓█   ▀  ██ ▀█   █ ▓██▒ ██▒ ▀█▒▓██▒▀█▀ ██▒▒████▄    ▓██   ▒  ▒██  ██▒
▒███   ▓██  ▀█ ██▒▒██▒▒██░▄▄▄░▓██    ▓██░▒██  ▀█▄  ▒████ ░   ▒██ ██░
▒▓█  ▄ ▓██▒  ▐▌██▒░██░░▓█  ██▓▒██    ▒██ ░██▄▄▄▄██ ░▓█▒  ░   ░ ▐██▓░
░▒████▒▒██░   ▓██░░██░░▒▓███▀▒▒██▒   ░██▒ ▓█   ▓██▒░▒█░      ░ ██▒▓░
░░ ▒░ ░░ ▒░   ▒ ▒ ░▓   ░▒   ▒ ░ ▒░   ░  ░ ▒▒   ▓▒█░ ▒ ░       ██▒▒▒ 
 ░ ░  ░░ ░░   ░ ▒░ ▒ ░  ░   ░ ░  ░      ░  ▒   ▒▒ ░ ░       ▓██ ░▒░ 
   ░      ░   ░ ░  ▒ ░░ ░   ░ ░      ░         ░  ░         ▒ ▒ ░░  
   ░  ░         ░  ░        ░        ░         ░  ░         ░ ░     
                                                            ░ ░     `
	fmt.Println(banner)
	fmt.Println("Developed by cibero42")
	fmt.Println("https://github.com/cibero42/enigmafy")
	fmt.Println("MIT License")
	fmt.Println("Version: 0.0.1")
}

func usage() {
	fmt.Println("Usage: enigmafy [-h] [-d gpg_key_file] [-e key_identity] [-s path/to/ssh/key] <directory_or_archive>")
	fmt.Println("\nOptions:")
	fmt.Println("  -d <gpg_key_file>: Specifies the GPG private key file for decryption mode.")
	fmt.Println("  -e <key_identity>: Specifies the GPG public key identity for encryption mode.")
	fmt.Println("  -h: Shows this help message.")
	fmt.Println("  -s <path/to/ssh/key>: Path to SSH key for signing/verification.")
	fmt.Println("  -v: Shows Enigmafy version.")
}

func compress() {
	fmt.Println("Compressing files...")
}

func decompress() {
	fmt.Println("Decompressing files...")
}

func main() {
	flag.BoolVar(&showHelp, "h", false, "Shows this help message.")
	flag.BoolVar(&showVersion, "v", false, "Shows this help message.")
	flag.Parse()

	if showHelp {
		usage()
		os.Exit(0)
	}

	if showVersion {
		version()
		os.Exit(0)
	}

	fmt.Println("Arguments are required!")
	os.Exit(1)
}
