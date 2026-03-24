#!/bin/bash
set -euo pipefail

TEST_SCRIPT="sync_backup.sh"
TEST_DIR="./test"
SRC_DIR="${TEST_DIR}/src"
DST_DIR="${TEST_DIR}/dst"
CONF_FILE="backup_list.conf"

rm -rf "${TEST_DIR}" "${CONF_FILE}"
mkdir -p "${SRC_DIR}" "${DST_DIR}"

cat <<EOF > "${CONF_FILE}"
SRC, DST
${SRC_DIR}, ${DST_DIR}
EOF

echo "file1" > "${SRC_DIR}/file1.txt"
echo "print(\"file2\")" > "${SRC_DIR}/file2.py"

bash "${TEST_SCRIPT}" 

echo "Test case: Check for copied correctly"
if [[ -f "${DST_DIR}/file1.txt" && -f "${DST_DIR}/file2.py" ]]; then
    if grep -q "file1" "${DST_DIR}/file1.txt" && grep -q "print(\"file2\")" "${DST_DIR}/file2.py"; then
        echo "OK"
    else
        echo "NG: didn't copy contents"
        exit 1
    fi
else
    echo "NG: didn't copy files"
    exit 1
fi

echo "Check for logs"
if grep -q "Integrity verification failed" ./log/"$(date +%Y%m%d)".log; then
    echo "OK"
else
    echo "NG"
fi

echo "Check for detecting tampering"
echo "tampered" > "${DST_DIR}/file1.txt"
bash "${TEST_SCRIPT}" --verify-only

if grep -q "Integrity verification failed" ./log/"$(date +%Y%m%d)".log; then
    echo "OK"
else
    echo "NG: Couldn't detect tampering"
fi

