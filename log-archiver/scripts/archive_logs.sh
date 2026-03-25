#!/bin/bash

# Delete archive files older than DELETE_DAYS
# Archive log files older than ARCHIVE_DAYS

set -euo pipefail

TARGET_DIR="${1:-}" 
ARCHIVE_DIR="${2:-./archive}"
ARCHIVE_DAYS="${3:-30}"
DELETE_DAYS="${4:-90}"

# --- Validation ---

# Check required the argument
if [[ -z "${TARGET_DIR}" ]]; then
    echo "Usage: $0 <target_dir> [archive_dir] [archive_days] [delete_days]" >&2
    exit 1
fi

# Check directory existence
if [[ ! -d "${TARGET_DIR}" ]]; then
    echo "Error: Directory ${TARGET_DIR} does not exist." >&2
    exit 1
fi

mkdir -p "${ARCHIVE_DIR}" 

# Check write permission for required dir
for dir in "${TARGET_DIR}" "${ARCHIVE_DIR}"; do
    if [[ ! -w "${dir}" ]]; then
        echo "Error: No write permission for ${dir}." >&2
        exit 1
    fi
done

# Validate the numeric arguments
for val in "${ARCHIVE_DAYS}" "${DELETE_DAYS}"; do
    if [[ ! "${val}" =~ ^[0-9]+$ ]]; then
        echo "Error: ${val} is not a valid number." >&2
        exit 1
    fi
done

# --- Main Logic---

echo "Log $(date '+%Y-%m-%d %H:%M:%S')"

# Delete archive files older than DELETE_DAYS
echo "Delete archives older than ${DELETE_DAYS} days"
find "${ARCHIVE_DIR}" -type f -mtime +"${DELETE_DAYS}" -name "*.tar.gz" -print -delete

# Archive log files older than ARCHIVE_DAYS
echo "Archive logs older than ${ARCHIVE_DAYS} days"
find "${TARGET_DIR}" -type f -mtime +"${ARCHIVE_DAYS}" -name "*.log" | while read -r file; do
    FILENAME="$(basename "${file}")"
    TIMESTAMP="$(date +%Y%m%d)"
    
    # One archive per a file
    if tar -czf "${ARCHIVE_DIR}/${FILENAME}_${TIMESTAMP}.tar.gz" -C "$(dirname "${file}")" "${FILENAME}"; then
        rm "${file}"
        echo "${file}"
    fi
done