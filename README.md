[![CircleCI](https://circleci.com/gh/amsainfor/aabrantes-pub-ssh-keys.svg?style=svg)](https://circleci.com/gh/amsainfor/aabrantes-pub-ssh-keys)



aabrantes-pub-ssh-keys
======================
This script will populate the `authorized_keys` file on a server with the entries in this repository. To run this script, use the following command (as root):

```
curl -s https://raw.githubusercontent.com/amsainfor/aabrantes-pub-ssh-keys/master/aabrantes-pub-keys.sh | bash
```

This script performs the following actions:

 * Adds our `aabrantes` management user.
 * Adds the `authorized_keys` file to that user's home directory.
 * Performs a checksum on this file.
 * Adds a cron entry to update this file on a scheduled basis.
 * Grants sudo permissions to the `aabrantes` user.



Packages you must have installed: `curl` and `sudo`

Checksum
========

To regenerate the checksum file before uploading, perform the following command:
```
md5sum authorized_keys > authorized_keys.md5sum
```
##### For Mac:
Install `md5sha1sum` via homebrew before running the `md5sum` command:
```
brew install md5sha1sum
md5sum authorized_keys > authorized_keys.md5sum
```

##### For Windows:
```
git clone git@github.com:<USERNAME>/pub-ssh-keys.git
git config core.autocrlf false
git reset --hard origin/master
md5sum authorized_keys > authorized_keys.md5sum
```
