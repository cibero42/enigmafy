package main

import (
	"archive/tar"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"
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
	fmt.Println("Usage: enigmafy [-h] [-d gpg_key_file] [-e key_identity] [-s path/to/ssh/key] source destination")
	fmt.Println("\nOptions:")
	fmt.Println("  -d <gpg_key_file>: Specifies the GPG private key file for decryption mode.")
	fmt.Println("  -e <key_identity>: Specifies the GPG public key identity for encryption mode.")
	fmt.Println("  -h: Shows this help message.")
	fmt.Println("  -s <path/to/ssh/key>: Path to SSH key for signing/verification.")
	fmt.Println("  -v: Shows Enigmafy version.")
}

func compress(source, destination string) error {
	// Compresses the source directory into a tar archive at the destination path.

	outFile, err := os.Create(destination)
	if err != nil {
		return fmt.Errorf("could not create output tar file %s: %w", destination, err)
	}
	defer outFile.Close()

	tarWriter := tar.NewWriter(outFile)
	defer tarWriter.Close()

	return filepath.Walk(source, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		relPath, err := filepath.Rel(source, path)
		if err != nil {
			return fmt.Errorf("could not get relative path for %s: %w", path, err)
		}

		if relPath == "." {
			return nil
		}

		header, err := tar.FileInfoHeader(info, filepath.ToSlash(relPath))
		if err != nil {
			return fmt.Errorf("could not create tar header for %s: %w", path, err)
		}

		header.Name = filepath.ToSlash(relPath)

		if err := tarWriter.WriteHeader(header); err != nil {
			return fmt.Errorf("could not write tar header for %s: %w", path, err)
		}

		if info.Mode().IsRegular() {
			file, err := os.Open(path)
			if err != nil {
				return fmt.Errorf("could not open file %s: %w", path, err)
			}
			defer file.Close() // Close the opened file when done

			if _, err := io.Copy(tarWriter, file); err != nil {
				return fmt.Errorf("could not copy file %s content to tar: %w", path, err)
			}
		}

		return nil
	})
}

func decompress() {
	fmt.Println("Decompressing files...")
}

func main() {
	// Get command-line flags
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

	// Get arguments
	args := flag.Args()
	if len(args) != 2 {
		fmt.Println("Error: Incorrect number of arguments.")
		usage()
		os.Exit(1)
	}
	sourceDir := args[0]
	destTarFile := args[1]

	// Check if source directory exists
	sourceInfo, err := os.Stat(sourceDir)
	if os.IsNotExist(err) {
		log.Fatalf("Error: Source directory '%s' does not exist.\n", sourceDir)
	}
	if !sourceInfo.IsDir() {
		log.Fatalf("Error: Source path '%s' is not a directory.\n", sourceDir)
	}

	if err := compress(sourceDir, destTarFile); err != nil {
		log.Fatalf("Error during tar operation: %v\n", err)
	}
	fmt.Printf("Successfully created '%s'.\n", destTarFile)

	fmt.Println("\nTo inspect the contents: `tar -tf", destTarFile, "`")
	fmt.Println("To extract: `tar -xf", destTarFile, "`")
}
