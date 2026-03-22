#!/bin/bash

LOG_FILE="status.log"
: > "${LOG_FILE}"

echo "Test case: Invalid argument"
if bash monitor_health.sh -10 80 80 2>&1 | grep -q "is not a valid number"; then
    echo "OK"
else
    echo "NG"
    exit 1
fi

echo "Test case: Set low thresholds to trigger an alert"
bash monitor_health.sh 1 1 1
if grep -q "exceeds threshold" "${LOG_FILE}"; then
    echo "OK"
else
    echo "NG"
    exit 1
fi

echo "Test case: Set high thresholds to suppress alerts"
bash monitor_health.sh 100 100 100
if tail -4 "${LOG_FILE}" | grep -q "exceeds threshold"; then
    echo "NG"
    exit 1
else
    echo "OK"
fi

echo "Test case: No write permission for log file"
touch readonly.log
chmod 444 readonly.log
if LOG_FILE="readonly.log" bash monitor_health.sh 1 1 1 2>&1 | grep -q "No write permission"; then
    echo "OK"
else
    echo "NG"
    exit 1
fi
rm -f readonly.log