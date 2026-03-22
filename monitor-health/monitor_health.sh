#!/bin/bash
set -euo pipefail

LOG_FILE="${LOG_FILE:-status.log}"
CPU_THR=${1:-80}
MEM_THR=${2:-80}
STG_THR=${3:-80}

for val in "${CPU_THR}" "${MEM_THR}" "${STG_THR}"; do
    if [[ ! "${val}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo "Error: ${val} is not a valid number." >&2
        exit 1
    fi
done

REQUIRED_CMDS=("ps" "awk" "df" "free" "top" "tail" "grep")
for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "${cmd}" >/dev/null 2>&1; then
        echo "Error: Required command '${cmd}' is not installed." >&2
        exit 1
    fi
done

LOG_DIR=$(dirname "${LOG_FILE}")
if [[ ! -d "${LOG_DIR}" ]]; then
    mkdir -p "${LOG_DIR}" || { echo "Error: Can't create directory ${LOG_DIR}." >&2; exit 1; }
fi

if [ -e "${LOG_FILE}" ]; then
    if [ ! -w "${LOG_FILE}" ]; then
        echo "Error: No write permission for ${LOG_FILE}." >&2
        exit 1
    fi
else
    if [ ! -w "${LOG_DIR}" ]; then
        echo "Error: No write permission for ${LOG_DIR}." >&2
        exit 1
    fi
fi

dump_detail(){
    local label=$1
    case "${label}" in
        "CPU")
            ps -ao user,pid,pcpu,pmem,comm --sort=-%cpu | head -6 >> "${LOG_FILE}" 
            ;;
        "MEM")
            ps -ao user,pid,pcpu,pmem,comm --sort=-%mem | head -6 >> "${LOG_FILE}" 
            ;;
        "STG")
            echo "SIZE    DIR" >> "${LOG_FILE}"
            du -hxd 1 / 2>/dev/null | sort -rh | head -5 >> "${LOG_FILE}" 
            ;;
    esac
}

check_threshold(){
    local label=$1 val=$2 thr=$3
    
    if  awk -v val="${val}" -v thr="${thr}" 'BEGIN {exit !( val >= thr)}' ; then
         local log_msg="${label} usage exceeds threshold: ${val}% (Threshold: ${thr}%)"
        echo "${log_msg}" >> "${LOG_FILE}"
        dump_detail "${label}"
    else
        echo "${label} usage: ${val}%" >> "${LOG_FILE}"
    fi
}

echo "---Health Check: $(date '+%Y-%m-%d %H:%M:%S') ---" >> "${LOG_FILE}"

CPU_USAGE=$(top -bn2 -d 0.5 | grep "Cpu(s)" | tail -1 | awk '{print 100 - $8}' )
MEM_USAGE=$(free | grep "Mem" | awk '{printf "%.1f", $3/$2 *100}')
STG_USAGE=$(df --output=pcent / | tail -1 | tr -d "%" | xargs)

check_threshold "CPU" "${CPU_USAGE}" "${CPU_THR}" 
check_threshold "MEM" "${MEM_USAGE}" "${MEM_THR}" 
check_threshold "STG" "${STG_USAGE}" "${STG_THR}" 