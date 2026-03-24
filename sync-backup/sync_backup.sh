#!/bin/bash
set -euo pipefail

CONFIG_FILE="backup_list.conf"
LOG_DIR="./log"
LOG_FILE="${LOG_DIR}/$(date +%Y%m%d).log"


mkdir -p "${LOG_DIR}"

VERIFY_ONLY=false
if [[ "${1:-}" == "-v" || "${1:-}" == "--verify-only" ]]; then
    VERIFY_ONLY=true
fi

verify_integrity() {
    local src="$1" dst="$2"

    local src_hash dst_hash
    
    src_hash=$(find "${src}" -maxdepth 1 -type f -exec sha256sum {} + | awk '{print $1}' | sort | sha256sum)
    dst_hash=$(find "${dst}" -maxdepth 1 -type f -exec sha256sum {} + | awk '{print $1}' | sort | sha256sum)

    if [[ "${src_hash}" == "${dst_hash}" ]]; then
        return 0
    else 
        return 1
    fi
}

if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "Error: ${CONFIG_FILE} not found"
    exit 1
fi

sed '1d' "${CONFIG_FILE}" | grep -v '^#' | grep -v '^$' | while IFS=',' read -r SRC_DIR DST_DIR; do

    SRC_DIR="$(echo "${SRC_DIR}" | xargs)"
    DST_DIR="$(echo "${DST_DIR}" | xargs)"

    if [[ "$VERIFY_ONLY" = true ]]; then
        if verify_integrity "${SRC_DIR}" "${DST_DIR}"; then
            echo "[VERIFIED]$(date '+%Y-%m-%d %H:%M:%S') : ${SRC_DIR} ${DST_DIR}" | tee -a "${LOG_FILE}" 
        else
            echo "[ERROR]$(date '+%Y-%m-%d %H:%M:%S') : Integrity verification failed ${SRC_DIR} ${DST_DIR}" | tee -a "${LOG_FILE}"
        fi
    else
        BACKUP_DIR="$(date +%Y%m%d)"
        mkdir -p "${DST_DIR}/${BACKUP_DIR}"
        if rsync -avz --delete --backup --backup-dir="${BACKUP_DIR}" "${SRC_DIR}/" "${DST_DIR}/" >> "${LOG_FILE}" 2>&1; then
    
            if verify_integrity "${SRC_DIR}" "${DST_DIR}"; then
                echo "[SUCCESS]$(date '+%Y-%m-%d %H:%M:%S') : Copied from ${SRC_DIR} to ${DST_DIR}, integrity verified" | tee -a "${LOG_FILE}"
            else
                echo "[ERROR]$(date '+%Y-%m-%d %H:%M:%S') : Copied from ${SRC_DIR} to ${DST_DIR}, Integrity verification failed" | tee -a "${LOG_FILE}"
            fi
        else
            rmdir "${DST_DIR}/${BACKUP_DIR}" 2>/dev/null || true
            echo "[ERROR]$(date '+%Y-%m-%d %H:%M:%S') : Failed to copy from ${SRC_DIR}" | tee -a "${LOG_FILE}"
        fi
    fi
done 