#!/bin/bash
# This shell script fetches all of the .torrent
# files associated with Fedora installation.

# Exit on failure of any command
set -e

# Variables
INDEX_URL=https://torrents.fedoraproject.org
TMP_FILE=/tmp/fedora_torrent.txt
TMP_ARCH_FILE=/tmp/debian_torrent_arch.txt
TMP_BT_FILE=/tmp/debian_torrent_bt.txt

# Fetch main index page
echo "Fetching main index page: ${INDEX_URL}/"
curl -s -L -o "${TMP_FILE}" "${INDEX_URL}/" # gets the html document

# Remove all lines without ".torrent" in them
cat ${TMP_FILE} | grep "\.torrent" | sed -n 's/.*href="\([^"]*\).*/\1/p' > "${TMP_FILE}.trimmed"

while read line
do
	echo "Downloading: ${line}"
	curl -s -L -o "${HOME}/torrents/watch/${line##https:/*/}" "${line}"
done < "${TMP_FILE}.trimmed"

