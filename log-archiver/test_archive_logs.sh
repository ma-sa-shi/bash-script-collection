#!/bin/bash

TEST_LOG_DIR="./test_logs"
TEST_ARCHIVE_DIR="./test_archive"
rm -rf "${TEST_LOG_DIR}" "${TEST_ARCHIVE_DIR}"
mkdir -p "${TEST_LOG_DIR}"

touch -d "100 days ago" "${TEST_LOG_DIR}/delete.log"
touch -d "40 days ago" "${TEST_LOG_DIR}/archive.log"
touch "${TEST_LOG_DIR}/keep.log"

ls -l "${TEST_LOG_DIR}"
bash ./archive_logs.sh "${TEST_LOG_DIR}" "${TEST_ARCHIVE_DIR}" 30 90