#!/bin/bash

# 目的: ストレージ容量を節約するため、
# 指定した日数を経過したログファイルのアーカイブと削除を自動化する
# アーカイブ先はデフォルトでカレントディレクトリ内の./archive

set -euo pipefail

TARGET_DIR="${1:-}" 
ARCHIVE_DIR="${2:-./archive}"
ARCHIVE_DAYS="${3:-30}"
DELETE_DAYS="${4:-90}"

# --- Validation ---

# 引数不足時は実行例を表示して中断
if [[ -z "${TARGET_DIR}" ]]; then
    echo "Usage: $0 <target_dir> [archive_dir] [archive_days] [delete_days]" >&2
    exit 1
fi


if [[ ! -d "${TARGET_DIR}" ]]; then
    echo "Error: Directory ${TARGET_DIR} does not exist." >&2
    exit 1
fi

mkdir -p "${ARCHIVE_DIR}" 

# 書き込み権限がないとtarやrmで失敗するため、事前に検証
for dir in "${TARGET_DIR}" "${ARCHIVE_DIR}"; do
    if [[ ! -w "${dir}" ]]; then
        echo "Error: No write permission for ${dir}." >&2
        exit 1
    fi
done

for val in "${ARCHIVE_DAYS}" "${DELETE_DAYS}"; do
    if [[ ! "${val}" =~ ^[0-9]+$ ]]; then
        echo "Error: ${val} is not a valid number." >&2
        exit 1
    fi
done

# --- Main Logic---

echo "Log $(date '+%Y-%m-%d %H:%M:%S')"

# DELETE_DAYSを経過したアーカイブを削除
echo "Delete archives older than ${DELETE_DAYS} days"
find "${ARCHIVE_DIR}" -type f -mtime +"${DELETE_DAYS}" -name "*.tar.gz" -print -delete

# 1ファイルずつログを圧縮してアーカイブ化
echo "Archive logs older than ${ARCHIVE_DAYS} days"
find "${TARGET_DIR}" -type f -mtime +"${ARCHIVE_DAYS}" -name "*.log" -print0 | while IFS= read -r -d '' file; do
    FILENAME="$(basename "${file}")"
    FILENAME_BASE="${FILENAME%.*}"
    TIMESTAMP="$(date +%Y%m%d)"

    DEST_FILE="${ARCHIVE_DIR}/${FILENAME_BASE}_${TIMESTAMP}.tar.gz"

    # 圧縮に成功した場合のみ、ログファイルを削除
    # アーカイブ内に余計なディレクトリ階層を含めないよう、ディレクトリを移動して実行
    if tar -czf "${DEST_FILE}" -C "$(dirname "${file}")" "${FILENAME}"; then
        rm "${file}"
        echo "${file}"
    fi
done