# Enigmafy
Enigmafy is a shell script which makes encrypting multiple archives an easy task.

## How it works
Under the hood, Enigmafy first compacts the desired archive or folder in a single file using gzip. Then, encrypts it using [AGE](https://github.com/FiloSottile/age). Optionally, the hash (SHA512) of the encrypted file is calculated and stored in a file which is signed with ssh keys.

When decrypting, Enigmafy can validate the signature and verify the hash, to validate integrity and authentication.

## Recommendations
### AGE
The private AGE key should be symmetrically encrypted in accordance with [NIST 800-63B](https://pages.nist.gov/800-63-3/sp800-63b.html) guidelines, which specifies a minimum length of 15 characters. This approach protects the private key against fast misuse by adversaries on [unsecured credentials](https://attack.mitre.org/techniques/T1552/004/) scenarios, as they would need to rely on [brute force](https://attack.mitre.org/techniques/T1110/).

To create a encrypted private key, run:
```
age-keygen | age -p > backup.age
```

## Installation
### 1. Clone the repository
```
git clone https://github.com/cibero42/enigmafy.git
```
### 2. Installation
The installation script requires root priviledges
```
cd enigmafy/
sudo ./install.sh
```

## Usage
### Encryption
To simply encrypt an archive:
```
enigmafy -e receivers_public_keys your_archive
```

It's also possible to calculate its hash and sign using a ssh key, via **-s** option
```
enigmafy -e receivers_public_keys -s private_ssh_key your_archive
```

You can send the encrypted archive to a S3 bucket using **-u**. Before using, you need to configure your remote in rclone, by running **rclone config**.
```
enigmafy -e receivers_public_keys -s private_ssh_key -u remote:your/bucket/path your_archive
```

### Decryption
To decrypt an archive:
```
enigmafy -d private_age_key your_archive.age
```

To verify the sender before decrypting:
```
enigmafy -d private_age_key -s sender_public_ssh_key your_archive.age
```

### Help
Run:
```
enigmafy -h
```