#!/bin/bash
# This shell script fetches all of the .torrent
# files associated with Debian installation.

# Exit on failure of any command
set -e

# Variables
INDEX_URL=http://cdimage.debian.org/debian-cd/current
TMP_FILE=/tmp/debian_torrent.txt
TMP_ARCH_FILE=/tmp/debian_torrent_arch.txt
TMP_BT_FILE=/tmp/debian_torrent_bt.txt

# Fetch main index page
echo "Fetching main index page: ${INDEX_URL}/"
curl -s -L -o "${TMP_FILE}" "${INDEX_URL}/" # gets the html document
# Sift through for links
cat ${TMP_FILE} | grep -e "href=\"[[:alnum:]].*\"" | sed -e 's/.*href=\"\([[:alnum:]]\+\).*/\1/g' > "${TMP_FILE}.trimmed"

# For each arch found on the main index
while read line_arch
do
	# Fetch each arch's index page
	echo "Fetching arch index page: ${INDEX_URL}/${line_arch}/"
	curl -s -L -o "${TMP_ARCH_FILE}" "${INDEX_URL}/${line_arch}/"
	# Sift through for bt-* links
	cat ${TMP_ARCH_FILE} | grep -e "href=\"bt-[[:alnum:]].*\"" | sed -e 's/.*href=\"\(bt-[[:alnum:]]\+\).*/\1/g' > "${TMP_ARCH_FILE}.trimmed"

	while read line_bt
	do
		# Fetch each arch's index page
		echo "Fetching bt index page: ${INDEX_URL}/${line_arch}/${line_bt}/"
		curl -s -L -o "${TMP_BT_FILE}" "${INDEX_URL}/${line_arch}/${line_bt}/"
		# Only save lines with ".torrent" to prune html hyper links we don't want
		cat ${TMP_BT_FILE} | grep "\.torrent" | sed -n 's/.*href="\([^"]*\).*/\1/p' > "${TMP_BT_FILE}.trimmed"
		# Select just the torrent name from the hyperlink
		#PARSE=$(sed -n 's/.*href="\([^"]*\).*/\1/p' ${TMP_BT_FILE})

		while read line_file
		do
			echo "downloading: ${INDEX_URL}/${line_arch}/${line_bt}/${line_file}"
			curl -s -L -o "${HOME}/torrents/watch/${line_file}" "${INDEX_URL}/${line_arch}/${line_bt}/${line_file}"
		done < "${TMP_BT_FILE}.trimmed"

	done < "${TMP_ARCH_FILE}.trimmed"

done < "${TMP_FILE}.trimmed"
