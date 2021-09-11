#!/bin/bash

# Fetches and prepares latest ota update from system server
# e.g.: https://system-image.ubports.com/16.04/arm64/android9/devel/on7xelte

URL='https://system-image.ubports.com'

CHANNEL="$1"
DEVICE="$2"
OUTPUT="$3"

mkdir -p "$OUTPUT" || true

download_file_and_asc() {
    wget "$1" -P "$2"
    wget "$1.asc" -P "$2"
}

# Gets the latest image from the system-image server
latest_image=$(wget -qO- "${URL}/${CHANNEL}/${DEVICE}/index.json" | jq '.images |  map(select(.type == "full")) | sort_by(.version) | .[-1]')

# Gets a list of files to download
files=$(echo "${latest_image}" | jq --raw-output '.files[].path')

# Downloads master and signing keyrings
download_file_and_asc "${URL}/gpg/image-signing.tar.xz" "$OUTPUT"
download_file_and_asc "${URL}/gpg/image-master.tar.xz" "$OUTPUT"

# Start to generate ubuntu_command file
echo '# Generated by ubports rootfs-builder-debos' > "$OUTPUT/ubuntu_command"

cat << EOF >> "$OUTPUT/ubuntu_command"
format system
load_keyring image-master.tar.xz image-master.tar.xz.asc
load_keyring image-signing.tar.xz image-signing.tar.xz.asc
mount system
EOF

# Download and fill ubuntu_command
for file_path in ${files}; do
    file=$(basename ${file_path})
    download_file_and_asc "${URL}/${file_path}" "$OUTPUT"
    echo "update $file $file.asc" >> "$OUTPUT/ubuntu_command"
done

# End ubuntu_command
echo 'unmount system' >> "$OUTPUT/ubuntu_command"
