#!/bin/bash
trap stop_process EXIT

LOG_FILE="./tests/status.log"
: > "${LOG_FILE}"

run_test() {
    local output
    output=$(bash ./scripts/monitor_health.sh "$@" 2>&1) 
    echo "${output}" >> ${LOG_FILE}
    echo "${output}"
}

stop_process(){
    if kill -0 "${LOAD_PID}" 2>/dev/null; then
        kill "${LOAD_PID}" >/dev/null 2>&1
        wait "${LOAD_PID}" 2>/dev/null
    fi
}

echo "Test case: Invalid argument"
if run_test -10 80 80 | grep -q "is not a valid number"; then
    echo "OK"
else
    echo "NG"
    exit 1
fi

echo "Test case: CPU Threshold"
timeout 1 yes > /dev/null &
LOAD_PID=$!
sleep 0.1
if run_test 1 100 100 | grep -q "CPU usage exceeds threshold"; then
    echo "OK, CPU alert triggered"
    if grep -q "yes" "${LOG_FILE}"; then
        echo "OK, detected \"yes\" in the PS list"
        stop_process
    else 
        echo "NG, didn't detect \"yes\" in the PS list"
        exit 1
    fi
else
    echo "NG, CPU alert didn't trigger"
    exit 1
fi

python3 -c "import time; x=' '*10**8; time.sleep(2)" & 
LOAD_PID=$!
sleep 0.1 
echo "Test case: MEM Threshold"
if run_test 100 1 100 | grep -q "MEM usage exceeds threshold"; then
    echo "OK, MEM alert triggered"
    if grep -q "python" "${LOG_FILE}"; then
        echo "OK, detected \"python\" in the PS list"
        stop_process
    else
        echo "NG, didn't detect \"python\" in the PS list"
        exit 1
    fi
else
    echo "NG, MEM alert didn't trigger"
    exit 1
fi

echo "Test case: STG Threshold"
if run_test 100 100 1 | grep -q "STG usage exceeds threshold"; then
    echo "OK"
else
    echo "NG"
    exit 1
fi

echo "Test case: Set high thresholds to suppress alerts"
if run_test 100 100 100 | grep -q "exceeds threshold"; then
    echo "NG"
    exit 1
else
    echo "OK"
fi

echo "All test cases passed"