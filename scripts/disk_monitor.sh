#!/bin/bash
# disk_monitor.sh
# Purpose: Log current disk usage with a timestamp, appending to a history file.


LOGFILE="$HOME/scripts/disk_usage.log"

echo "----- $(date) -----" >> "$LOGFILE"
df -h >> "$LOGFILE"
echo "" >> "$LOGFILE"
