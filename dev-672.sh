#!/bin/bash
set -euxo pipefail

NFS_SERVER=172.21.188.152
BASE_DIR="/opt/spaces/raw_data"

ssh cellwize@${NFS_SERVER} "ls ${BASE_DIR}/NOKIA" > OSS_IDs.txt
ssh cellwize@${NFS_SERVER} "ls ${BASE_DIR}/SAMSUNG" >> OSS_IDs.txt
