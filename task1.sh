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

# Function: Top 10 memory consuming processes
top_processes() {
    echo "---- Top 10 Memory Consuming Processes ----"
    ps -eo pid,user,%cpu,%mem,comm --sort=-%mem | head -11
    log_action "Viewed top 10 memory consuming processes"
}

# Function: Kill process safely
kill_process() {
    read -p "Enter PID to terminate: " pid

    # Prevent killing critical processes
    critical_pids=("1" "2")

    for cp in "${critical_pids[@]}"; do
        if [ "$pid" == "$cp" ]; then
            echo "❌ Cannot terminate critical system process (PID $pid)"
            log_action "Attempted to kill critical process PID $pid"
            return
        fi
    done

    if ps -p $pid > /dev/null
    then
        read -p "Are you sure you want to terminate process $pid? (Y/N): " confirm
        if [[ "$confirm" == "Y" || "$confirm" == "y" ]]; then
            kill $pid
            echo "✅ Process $pid terminated."
            log_action "Terminated process PID $pid"
        else
            echo "Cancelled."
            log_action "Cancelled termination of PID $pid"
        fi
    else
        echo "❌ Invalid PID"
    fi
}

# Function: Disk usage
disk_usage() {
    read -p "Enter directory path: " dir

    if [ -d "$dir" ]; then
        du -sh "$dir"
        log_action "Checked disk usage of $dir"
    else
        echo "❌ Directory not found"
    fi
}