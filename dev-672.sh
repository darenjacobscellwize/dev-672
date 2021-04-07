#!/bin/bash
set -euxo pipefail

NOKIA_INPUT_FILE="n_file.txt"
SAMSUNG_INPUT_FILE="s_file.txt"

get_data() {
  NFS_SERVER=172.21.188.152
  BASE_DIR="/opt/spaces/raw_data/network"

  ssh cellwize@${NFS_SERVER} "ls ${BASE_DIR}/NOKIA" > ${NOKIA_INPUT_FILE}
  ssh cellwize@${NFS_SERVER} "ls ${BASE_DIR}/SAMSUNG" > ${SAMSUNG_INPUT_FILE}
}

read_file() {
  while read f; do
    # echo "$f"
  sed -e 's/\(^.*_\)\(.*\)\(_.*$\)/\2/' <<< "$f"
  done < $FILE_TO_READ
}

process_files() {
  for file in ${NOKIA_INPUT_FILE} ${SAMSUNG_INPUT_FILE}
  do
    FILE_TO_READ=${file}
    if [ $file = ${NOKIA_INPUT_FILE} ]; then
      read_file >> n_OSS_IDs.txt
    elif [ $file = ${SAMSUNG_INPUT_FILE} ]; then
      read_file >> s_OSS_IDs.txt
    else
      echo "ERROR unknown file"
    fi
  done
}

get_data
process_files
