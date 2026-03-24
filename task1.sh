#!/bin/bash

LOG_FILE="system_monitor_log.txt"
ARCHIVE_DIR="ArchiveLogs"

# Function to log actions
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Function: Display CPU & Memory usage
show_system_usage() {
    echo "---- CPU & Memory Usage ----"
    top -b -n1 | head -5
    log_action "Viewed CPU and memory usage"
}