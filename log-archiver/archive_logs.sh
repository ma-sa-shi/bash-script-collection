#!/bin/bash

TARGET_DIR="${1}" 
ARCHIVE_DIR="${2:-./archive}"
ARCHIVE_DAYS="${3:-30}"
DELETE_DAYS="${4:-90}"

mkdir -p "${ARCHIVE_DIR}"

echo "Log $(date '+%Y-%m-%d %H:%M:%S')"

echo "Delete logs older than ${DELETE_DAYS} days"
find "${TARGET_DIR}" -type f -mtime +"${DELETE_DAYS}" -name "*.log" -print -delete

echo "Archive logs older than ${ARCHIVE_DAYS} days"
find "${TARGET_DIR}" -type f -mtime +"${ARCHIVE_DAYS}" -name "*.log" | while read -r file; do
    FILENAME=$(basename "${file}")
    TIMESTAMP=$(date +%Y%m%d)
    
    if tar -czf "${ARCHIVE_DIR}/${FILENAME}_${TIMESTAMP}.tar.gz" "${file}"; then
        rm "${file}"
        echo "${file}"
    fi
done