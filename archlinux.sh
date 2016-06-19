#!/bin/bash
# This shell script downloads the handful of most recent archlinux
# installation media torrent files to a watch folder.

set -e

# Variables
INDEX_URL=https://www.archlinux.org/feeds/releases
TMP_HTML=/tmp/archlinux_tracker.html

# Fetch the RSS page
curl -s -L -o ${TMP_HTML} "${INDEX_URL}/"

# The XML has no linebreaks, add some
sed -i -e 's/</\n</g' "${TMP_HTML}"

# Remove all lines without ".torrent" in them
cat ${TMP_HTML} | grep "\.torrent" | sed -n 's/.*url="\([^"]*\).*/\1/p' > "${TMP_HTML}.trimmed"

while read line
do
	echo "Downloading: ${line}"
	curl -s -L -o "${HOME}/torrents/watch/${line##https:/*/}" "${line}"
done < "${TMP_HTML}.trimmed"
