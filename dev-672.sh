#!/bin/bash
set -euxo pipefail

NOKIA_INPUT_FILE="n_file.txt"
SAMSUNG_INPUT_FILE="s_file.txt"
NOKIA_OUTPUT_FILE="n_OSS_IDs.txt"
SAMSUNG_OUTPUT_FILE="s_OSS_IDs.txt"
SQL_FILE="load_oss_info.sql"

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
      read_file >> ${NOKIA_OUTPUT_FILE}
    elif [ $file = ${SAMSUNG_INPUT_FILE} ]; then
      read_file >> ${SAMSUNG_OUTPUT_FILE}
    else
      echo "ERROR unknown file"
    fi
  done
}

create_sql_file(){
echo "--
-- Database: \`son\`
--

-- --------------------------------------------------------

--
-- Table structure for table \`oss_info\`
--

CREATE TABLE IF NOT EXISTS \`oss_info\` (
  \`id\` bigint(20) NOT NULL AUTO_INCREMENT,
  \`created\` datetime DEFAULT NULL,
  \`deleted\` datetime DEFAULT NULL,
  \`description\` varchar(255) DEFAULT NULL,
  \`localId\` varchar(255) DEFAULT NULL,
  \`name\` varchar(255) DEFAULT NULL,
  \`vendor\` varchar(255) DEFAULT NULL,
  \`params\` varchar(255) DEFAULT \'operator=unknown\',
  \`isProvSuspended\` tinyint(10) DEFAULT b\'0\',
  PRIMARY KEY (\`id\`)
)

--
-- Dumping data for table \`oss_info\`
--
INSERT INTO \`oss_info\` (\`id\`, \`description\`, \`localId\`, \`name\`, \`vendor\`) VALUES" > ${SQL_FILE}

}

update_sql_file() {
  id_number=9
  for file in ${NOKIA_OUTPUT_FILE} ${SAMSUNG_OUTPUT_FILE}
  do
    while IFS= read -r line
    do
      echo "$line"
      if [ $file = ${NOKIA_OUTPUT_FILE} ]; then
        description="Samsung"
        vendor="SAMSUNG_LTE"
        echo "($id_number,'${description} OSS $line','$line','$line','$vendor')" >> ${SQL_FILE}
      elif [ $file = ${SAMSUNG_OUTPUT_FILE} ]; then
        vendor="NOKIA"
        echo "($id_number,'${vendor} OSS $line','$line','$line','$vendor')" >> ${SQL_FILE}
      fi
      let "id_number=id_number+1"
    done < "$file"
  done
}

execute_script() {
  if [ -f "${SQL_FILE}" ]; then
    rm ${SQL_FILE}
  fi
  get_data
  process_files
  create_sql_file
  update_sql_file
  rm  $NOKIA_INPUT_FILE $NOKIA_OUTPUT_FILE $SAMSUNG_INPUT_FILE $SAMSUNG_OUTPUT_FILE
}

execute_script
