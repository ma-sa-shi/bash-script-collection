#!/bin/bash
set -euo pipefail

LOG_FILE="status.log"

check_threshold(){
    local label=$1 val=$2 thr=$3
    
    if  awk -v val="${val}" -v thr="${thr}" 'BEGIN {exit !( val >= thr)}' ; then
        log_msg="${label} usage exceeds threshold: ${val}% (Threshold: ${thr}%)"
        echo "${log_msg}" >> "${LOG_FILE}"
    else
        echo "${label} usage: ${val}%" >> "${LOG_FILE}"
    fi
}

echo "---Health Check: $(date '+%Y-%m-%d %H:%M:%S') ---" >> "${LOG_FILE}"

CPU_USAGE=$(top -bn2 -d 0.1 | grep "Cpu(s)" | tail -1 | awk '{print 100 - $8}' )
MEM_USAGE=$(free | grep "Mem" | awk '{print($3/$2 *100)}')
STG_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d "%")

CPU_THR=${1:-80}
MEM_THR=${2:-80}
STG_THR=${3:-80}

check_threshold "CPU" "${CPU_USAGE}" "${CPU_THR}" 
check_threshold "MEM" "${MEM_USAGE}" "${MEM_THR}" 
check_threshold "STG" "${STG_USAGE}" "${STG_THR}" 