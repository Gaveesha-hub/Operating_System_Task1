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

# Function: Log archiving
archive_logs() {

    read -p "Enter directory to search log files: " search_dir

    if [ ! -d "$search_dir" ]; then
        echo "❌ Directory not found"
        return
    fi

    # Create ArchiveLogs if not exists
    if [ ! -d "$ARCHIVE_DIR" ]; then
        mkdir "$ARCHIVE_DIR"
        log_action "Created ArchiveLogs directory"
    fi

    echo "🔍 Searching for log files >50MB in $search_dir..."

    found=false

    while IFS= read -r file
    do
        found=true

        timestamp=$(date '+%Y%m%d_%H%M%S')
        filename=$(basename "$file")

        gzip -c "$file" > "$ARCHIVE_DIR/${filename}_${timestamp}.gz"

        if [ $? -eq 0 ]; then
            echo "✅ Archived: $file"
            log_action "Archived $file"
        else
            echo "❌ Failed to archive: $file"
            log_action "Failed to archive $file"
        fi

    done < <(find "$search_dir" -type f -name "*.log" -size +50M 2>/dev/null)

    if [ "$found" = false ]; then
        echo "⚠ No log files larger than 50MB found."
    fi

    # Check ArchiveLogs size
    size=$(du -sm "$ARCHIVE_DIR" | cut -f1)

    if [ "$size" -gt 1024 ]; then
        echo "⚠ WARNING: ArchiveLogs exceeds 1GB!"
        log_action "Warning: ArchiveLogs exceeded 1GB"
    fi
}


# Exit function

exit_system() {
    read -p "Are you sure you want to exit? (Y/N): " confirm
    if [[ "$confirm" == "Y" || "$confirm" == "y" ]]; then
        log_action "Exited system"
        echo "Bye!"
        exit 0
    else
        echo "Returning to menu..."
    fi
}