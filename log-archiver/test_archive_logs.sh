#!/bin/bash

set -euo pipefail

SCRIPT="./archive_logs.sh"
TEST_TARGET_DIR="./test_logs"
TEST_ARCHIVE_DIR="./test_archive"

is_exist() {
    if [[ -f "$1" ]]; then 
        echo "OK: $1 exists"; 
    else 
        echo "NG: $1 missing"; 
        exit 1; 
    fi
}

is_not_exist() {
    if [[ ! -e "$1" ]]; then 
        echo "OK: $1 deleted"; 
    else 
        echo "NG: $1 still exits"; 
        exit 1; 
    fi
}

rm -rf "${TEST_TARGET_DIR}" "${TEST_ARCHIVE_DIR}" 
mkdir -p "${TEST_TARGET_DIR}" "${TEST_ARCHIVE_DIR}"
ls -l "${TEST_TARGET_DIR}"

echo "--- Normal test case ---"

touch -d "10 days ago" "${TEST_TARGET_DIR}/keep.log"
touch -d "40 days ago" "${TEST_TARGET_DIR}/archive.log"
touch -d "50 days ago" "${TEST_ARCHIVE_DIR}/keep.tar.gz"
touch -d "100 days ago" "${TEST_ARCHIVE_DIR}/delete.tar.gz"

bash ${SCRIPT} "${TEST_TARGET_DIR}" "${TEST_ARCHIVE_DIR}" 30 90

is_exist "${TEST_TARGET_DIR}/keep.log"
is_exist "${TEST_ARCHIVE_DIR}/archive.log_$(date +%Y%m%d).tar.gz"
is_not_exist "${TEST_TARGET_DIR}/archive.log"
is_exist "${TEST_ARCHIVE_DIR}/keep.tar.gz"
is_not_exist "${TEST_ARCHIVE_DIR}/delete.tar.gz"

echo "--- Error handling test case ---"

echo "Test case:The required argument \"TEST_TARGET_DIR\" isn't given"
if bash ${SCRIPT} "" 2>/dev/null; then
    echo "NG"
    exit 1
else
    echo "OK"
fi

echo "Test case:ARCHIVE_DAYS is invalid"
if bash ${SCRIPT} "${TEST_TARGET_DIR}" "${TEST_ARCHIVE_DIR}" "-10" 90 2>/dev/null; then
    echo "NG"
    exit 1
else
    echo "OK"
fi

echo "Test case:DELETE_DAYS is invalid"
if bash ${SCRIPT} "${TEST_TARGET_DIR}" "${TEST_ARCHIVE_DIR}" 30 "-10"  2>/dev/null; then
    echo "NG"
    exit 1
else
    echo "OK"
fi

echo "Test case:TEST_TARGET_DIR isn't exist"
rm -rf "./not_exist_dir"
if bash ${SCRIPT} "./not_exist_dir" "${TEST_ARCHIVE_DIR}" 30 90 2>/dev/null; then
    echo "NG"
    exit 1
else 
    echo "OK"
fi

echo "Test case:TEST_TARGET_DIR has no write permission"
chmod 555 "${TEST_TARGET_DIR}"
if bash "${SCRIPT}" "${TEST_TARGET_DIR}" "${TEST_ARCHIVE_DIR}" 30 90 2>/dev/null; then
    echo "NG"
    exit 1
else 
    echo "OK"
    chmod 755 "${TEST_TARGET_DIR}"
fi

echo "Test case:TEST_ARCHIVE_DIR has no write permission"
chmod 555 "${TEST_ARCHIVE_DIR}"
if bash "${SCRIPT}" "${TEST_TARGET_DIR}" "${TEST_ARCHIVE_DIR}" 30 90 2>/dev/null; then
    echo "NG"
    exit 1
else 
    echo "OK"
    chmod 755 "${TEST_ARCHIVE_DIR}"
fi

echo "All test cases passed"