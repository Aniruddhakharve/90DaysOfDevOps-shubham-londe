# Shell Scripting Cheat Sheet

This document is my personal quick reference for Bash scripting concepts that I learned during the DevOps journey. It contains common syntax, commands and examples that are frequently used in automation and troubleshooting.

---

# Quick Reference Table

| Topic | Key Syntax | Example |
|------|------------|--------|
| Variable | VAR="value" | NAME="DevOps" |
| Argument | $1 $2 | ./script.sh arg1 |
| If condition | if [ condition ]; then | if [ -f file ]; then |
| For loop | for i in list; do | for i in 1 2 3; do |
| Function | name() { } | greet() { echo "Hi"; } |
| Grep | grep pattern file | grep -i "error" log.txt |
| Awk | awk '{print $1}' file | awk -F: '{print $1}' /etc/passwd |
| Sed | sed 's/old/new/g' file | sed -i 's/foo/bar/g' config.txt |

---

# 1. Basics

## Shebang

Specifies which interpreter should execute the script.

```bash
#!/bin/bash
```

## Running Scripts

```bash
chmod +x script.sh
./script.sh
bash script.sh
```

## Comments

```bash
# single line comment
echo "hello" # inline comment
```

## Variables

```bash
NAME="Alex"
echo $NAME
echo "$NAME"
echo '$NAME'
```

## Reading User Input

```bash
read -p "Enter name: " NAME
echo "Hello $NAME"
```

## Command Line Arguments

```bash
echo $0   # script name
echo $1   # first argument
echo $#   # number of arguments
echo $@   # all arguments
echo $?   # last command exit status
```

---

# 2. Operators and Conditionals

## String Comparisons

```bash
[ "$A" = "$B" ]
[ "$A" != "$B" ]
[ -z "$VAR" ]
[ -n "$VAR" ]
```

## Integer Comparisons

```bash
[ $A -eq $B ]
[ $A -ne $B ]
[ $A -lt $B ]
[ $A -gt $B ]
[ $A -le $B ]
[ $A -ge $B ]
```

## File Tests

```bash
[ -f file ]   # file exists
[ -d dir ]    # directory exists
[ -e file ]   # exists
[ -r file ]   # readable
[ -w file ]   # writable
[ -x file ]   # executable
[ -s file ]   # not empty
```

## If Else

```bash
if [ -f file.txt ]; then
  echo "File exists"
elif [ -d dir ]; then
  echo "Directory exists"
else
  echo "Not found"
fi
```

## Logical Operators

```bash
[ condition1 ] && echo "true"
[ condition1 ] || echo "false"
! command
```

## Case Statement

```bash
case $VAR in
  start) echo "Starting";;
  stop) echo "Stopping";;
  *) echo "Unknown";;
esac
```

---

# 3. Loops

## For Loop

```bash
for i in 1 2 3
do
  echo $i
done
```

## C-Style For Loop

```bash
for ((i=1;i<=5;i++))
do
  echo $i
done
```

## While Loop

```bash
while read line
do
  echo $line
done < file.txt
```

## Until Loop

```bash
until [ $count -gt 5 ]
do
  echo $count
  ((count++))
done
```

## Break and Continue

```bash
break
continue
```

## Loop Over Files

```bash
for file in *.log
do
  echo $file
done
```

---

# 4. Functions

## Define Function

```bash
greet() {
  echo "Hello $1"
}
```

## Call Function

```bash
greet Alex
```

## Function Arguments

```bash
add() {
  echo $(($1 + $2))
}
```

## Return Values

```bash
return 0
echo "value"
```

## Local Variables

```bash
func() {
  local VAR="inside"
}
```

---

# 5. Text Processing Commands

## grep

```bash
grep "error" log.txt
grep -i "error" log.txt
grep -n "error" log.txt
grep -r "error" /var/log
grep -c "error" log.txt
```

## awk

```bash
awk '{print $1}' file
awk -F: '{print $1}' /etc/passwd
```

## sed

```bash
sed 's/foo/bar/g' file
sed -i 's/foo/bar/g' file
sed '5d' file
```

## cut

```bash
cut -d: -f1 /etc/passwd
```

## sort

```bash
sort file.txt
sort -n numbers.txt
sort -r file.txt
```

## uniq

```bash
uniq file.txt
uniq -c file.txt
```

## tr

```bash
tr 'a-z' 'A-Z'
```

## wc

```bash
wc -l file
wc -w file
wc -c file
```

## head / tail

```bash
head -n 10 file
tail -n 10 file
tail -f logfile
```

---

# 6. Useful One-Liners

## Delete files older than 7 days

```bash
find /path -name "*.log" -mtime +7 -delete
```

## Count lines in all log files

```bash
wc -l *.log
```

## Replace text in multiple files

```bash
sed -i 's/old/new/g' *.txt
```

## Check if service is running

```bash
systemctl is-active nginx
```

## Monitor disk usage

```bash
df -h
```

---

# 7. Error Handling and Debugging

## Exit Codes

```bash
echo $?
exit 0
exit 1
```

## Exit on Error

```bash
set -e
```

## Undefined Variables

```bash
set -u
```

## Pipe Failures

```bash
set -o pipefail
```

## Debug Mode

```bash
set -x
```

## Trap Cleanup

```bash
trap 'echo cleanup' EXIT
```

---

# What I Learned

- Bash scripting is powerful for automating system administration tasks.
- Linux text processing tools like grep, awk and sed make log analysis easier.
- Writing a cheat sheet helps reinforce concepts and provides a quick reference for real-world troubleshooting.
