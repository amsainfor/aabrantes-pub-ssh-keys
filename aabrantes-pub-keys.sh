#!/usr/bin/env bash
set -e

# Check for CI
if [ "$CI" = "true" ] ; then
        BRANCH=$CIRCLE_SHA1
        echo "Testing commit: $BRANCH"
else
        BRANCH="master"
fi

# Variables
AMSAINFORUSER="aabrantes"
AMSAINFORHOME="/home/aabrantes"
AMSAINFORSCRIPT="https://raw.githubusercontent.com/amsainfor/aabrantes-pub-ssh-keys/$BRANCH/aabrantes-pub-keys.sh"
AMSAINFORKEYS="https://raw.githubusercontent.com/amsainfor/aabrantes-pub-ssh-keys/$BRANCH/authorized_keys"
AMSAINFORCHECKSUM="https://raw.githubusercontent.com/amsainfor/aabrantes-pub-ssh-keys/$BRANCH/authorized_keys.md5sum"

# Require script to be run via sudo, but not as root
if [[ $EUID -ne 0 ]]; then
    echo "Script must be run with root privilages!"
    exit 1
fi

# Add and configure aabrantes user access
if getent passwd $AMSAINFORUSER > /dev/null; then
	echo "AMSAINFOR Management User already exists...Skipping"
else
	echo -n "Adding the AMSAINFOR Management User..."
	useradd -m -d $AMSAINFORHOME $AMSAINFORUSER
	echo "Done"
fi

echo -n "Checking file checksum..."
mkdir -p $AMSAINFORHOME/.ssh
curl -s -o $AMSAINFORHOME/.ssh/authorized_keys.md5sum $AMSAINFORCHECKSUM
curl -s -o $AMSAINFORHOME/.ssh/authorized_keys $AMSAINFORKEYS
(cd $AMSAINFORHOME/.ssh && md5sum -c authorized_keys.md5sum)

echo -n "Correcting SSH configuration permissions..."
chmod 600 $AMSAINFORHOME/.ssh/authorized_keys
chmod 500 $AMSAINFORHOME/.ssh
chown -R $AMSAINFORUSER:$AMSAINFORUSER $AMSAINFORHOME/.ssh
echo "Done"

if [ -f $AMSAINFORHOME/aabrantes.cron ]; then
	echo "Crontab already configured for updates...Skipping"
else
	echo -n "Adding crontab entry for continued updates..."
	echo "MAILTO=\"\"" > $AMSAINFORHOME/aabrantes.cron
	echo "" >> $AMSAINFORHOME/aabrantes.cron
	echo "@reboot curl -s $AMSAINFORSCRIPT | sudo bash" >> $AMSAINFORHOME/aabrantes.cron
	echo "*/15 * * * * curl -s $AMSAINFORSCRIPT | sudo bash" >> $AMSAINFORHOME/aabrantes.cron
	crontab -u $AMSAINFORUSER $AMSAINFORHOME/aabrantes.cron
	echo "Done"
fi

if [ -f /etc/sudoers.d/aabrantes-user ]; then
	echo "Sudo already configured for AMSAINFOR Management User...Skipping"
else
	echo -n "Configuring sudo for AMSAINFOR Management User..."
	echo "# AMSAINFOR user allowed sudo access" > /etc/sudoers.d/aabrantes-user
	echo "$AMSAINFORUSER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/aabrantes-user
	echo "Defaults:$AMSAINFORUSER !requiretty" >> /etc/sudoers.d/aabrantes-user
	echo "" >> /etc/sudoers.d/aabrantes-user
	chmod 440 /etc/sudoers.d/aabrantes-user
	echo "Done"
fi
