#!/bin/bash

# Log Archive Tool
# roadmap.sh DevOps Project


# Default values
log_dir="/var/log"
days_to_keep_logs=7
days_to_keep_backups=30

archive_dir="$HOME/log-archives"


# Function for input with default value
prompt_for_input() {
    read -r -p "$1 [$2]: " input
    echo "${input:-$2}"
}


# Archive function
run_archive() {

    if [ ! -d "$log_dir" ]; then
        echo "Error: Log directory does not exist."
        return 1
    fi


    mkdir -p "$archive_dir"


    timestamp=$(date +"%Y%m%d_%H%M%S")

    archive_file="$archive_dir/logs_archive_${timestamp}.tar.gz"


    echo "Creating archive..."

    tar -czf "$archive_file" "$log_dir"


    if [ $? -eq 0 ]; then
        echo "Archive created successfully:"
        echo "$archive_file"
    else
        echo "Archive failed"
        return 1
    fi


    echo "Archive created at $(date)" >> "$archive_dir/archive_log.txt"


    echo "Removing logs older than $days_to_keep_logs days..."

    find "$log_dir" \
    -type f \
    -mtime +$days_to_keep_logs \
    -not -path "$archive_dir/*" \
    -exec rm -f {} \;


    echo "Removing old archives..."

    find "$archive_dir" \
    -type f \
    -name "*.tar.gz" \
    -mtime +$days_to_keep_backups \
    -exec rm -f {} \;


    echo "Cleanup completed."

}


# Setup cron
setup_cron() {

    read -r -p "Add daily cron job? (y/n): " choice


    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then

        SCRIPT_PATH=$(realpath "$0")

        cron_line="0 2 * * * $SCRIPT_PATH"


        (crontab -l 2>/dev/null; echo "$cron_line") | crontab -


        echo "Cron added:"
        echo "$cron_line"

    else
        echo "Cron not added."
    fi

}


# Main menu

while true; do

    echo
    echo "================================"
    echo "       LOG ARCHIVE TOOL"
    echo "================================"

    echo "Current log directory: $log_dir"
    echo "Keep logs: $days_to_keep_logs days"
    echo "Keep archives: $days_to_keep_backups days"

    echo

    echo "1. Set Log Directory"
    echo "2. Set Log Retention Days"
    echo "3. Set Archive Retention Days"
    echo "4. Run Archive"
    echo "5. Setup Cron"
    echo "6. Exit"


    read -r -p "Choose option [1-6]: " choice


    case $choice in

        1)
            log_dir=$(prompt_for_input "Log directory" "$log_dir")

            if [ ! -d "$log_dir" ]; then
                echo "Directory does not exist."
                log_dir="/var/log"
            fi
            ;;


        2)
            days_to_keep_logs=$(prompt_for_input "Days to keep logs" "$days_to_keep_logs")
            ;;


        3)
            days_to_keep_backups=$(prompt_for_input "Days to keep archives" "$days_to_keep_backups")
            ;;


        4)
            run_archive
            ;;


        5)
            setup_cron
            ;;


        6)
            echo "Exiting..."
            exit 0
            ;;


        *)
            echo "Invalid option."
            ;;

    esac

done