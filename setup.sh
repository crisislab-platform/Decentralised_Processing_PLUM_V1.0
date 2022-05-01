#!/bin/bash

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

set -Ee

function _catch {
    echo "An error has occured in the script. Please contact Chanthujan at CRISiSLab for assistance."
    exit 0  # optional; use if you don't want to propagate (rethrow) error to outer shell
}

trap _catch ERR

cd "$(dirname "$0")"

echo Installing dependencies
pip install -r requirements.txt

# Install as service
echo Installing service
sed -i 's/<token>/'$(dirname "$0")'/g' plum-client.service
cp plum-client.service /etc/systemd/system/plum-client.service
systemctl daemon-reload
systemctl enable plum-client.service
systemctl start plum-client.service

(crontab -l ; echo "0 0 * ? * * * cd $(dirname "$0"); git pull") | crontab -

echo Done\! Your sensor is now running the PLUM client.
