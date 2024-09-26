# Enigmafy
Enigmafy is a shell script which makes encrypting multiple archives an easy task. The script generates two files, ending in: .ek (enigmafy key) and .eea (enigmafy encrypted archive)

## Features
- AES-256 encrypted archives, with pseudo-randomly generated password.
- [UNDER DEVELOPMENT] Upload archives to S3 services

## Installation
TODO

## Usage
### Encryption
To encrypt an archive called "your_archive" for gpg@key.org:
```
enigmafy -e gpg@key.org your_archive
```

It's also possible to set AES256 random password size, via **-k** option (the default is 64 characters):
```
enigmafy -e gpg@key.org -k 128 your_archive
```

### Decryption
To decrypt an archive:
```
enigmafy -d your_archive.ek your_archive.eea
```

### Help
Run:
```
enigmafy -h
```