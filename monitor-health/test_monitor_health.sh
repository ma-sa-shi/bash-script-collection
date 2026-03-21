#!/bin/bash

LOG_FILE="status.log"
: > "${LOG_FILE}"

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
