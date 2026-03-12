#!/bin/bash

# -------------------------------
# Log Analyzer Script
# This script analyzes a log file
# and generates a summary report
# -------------------------------

# Check if argument is provided
 
if [ $# -eq 0 ]; then
	echo  "Usage: ./log_analyzer.sh <log_file>"
	exit 1
fi

LOGFILE=$1

if [ ! -f "$LOGFILE" ]; then
	echo "Error: Log file does not exist"
	exit 1
fi

echo " Analyzing log file: $LOGFILE "

#get total no of line in file
TOTAL_LINES=$( wc -l < "$LOGFILE" )

#count the the ERROR or FAIL the file have
ERROR_COUNT=$( grep -E "ERROR|Failed" "$LOGFILE" | wc -l ) 

echo " TOTAL ERRORS : $ERROR_COUNT "
echo
echo "========= Critica Events ========"

# Print CRITICAL events with line numbers
grep -n "CRITICAL" "$LOGFILE"


echo
echo "--- Top 5 Error Messages ---"

grep "ERROR" "$LOGFILE" \
| awk '{$1=$2=$3=""; print}' \
| sort \
| uniq -c \
| sort -rn \
| head -5

# Create report file with current date

DATE=$(date +%Y-%m-%d)
REPORT="log_report_$DATE.txt"

{
echo "Log Analysis Report"
echo "Date: $DATE"
echo "Log File: $LOGFILE"
echo "Total Lines: $TOTAL_LINES"
echo "Total Errors: $ERROR_COUNT"

echo
echo "Top 5 Error Messages:"
grep "ERROR" "$LOGFILE" \
| awk '{$1=$2=$3=""; print}' \
| sort \
| uniq -c \
| sort -rn \
| head -5

echo
echo "Critical Events:"
grep -n "CRITICAL" "$LOGFILE"

} > "$REPORT"

echo
echo "Report generated: $REPORT"

# Optional: archive processed logs

mkdir -p archive
mv "$LOGFILE" archive/

echo "Log file moved to archive/"

