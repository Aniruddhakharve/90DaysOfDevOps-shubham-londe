# Day 16 – Shell Scripting Basics

Aaj maine Bash shell scripting ke basic concepts practice kiye. Is exercise me maine simple scripts banaye jisme variables, user input aur conditional statements ka use kiya.

------------------------------------------------------------

## Task 1 – First Script

File: hello.sh

Script:

#!/bin/bash
echo "Hello, DevOps!"

Run commands:

chmod +x hello.sh
./hello.sh

Output:

Hello, DevOps!

Observation:

Shebang line (#!/bin/bash) system ko batati hai ki script ko bash interpreter se run karna hai. Agar shebang remove kar diya jaye to script run ho sakti hai, lekin kabhi kabhi incorrect interpreter use ho sakta hai.

------------------------------------------------------------

## Task 2 – Variables

File: variables.sh

Script:

#!/bin/bash

NAME="Alex"
ROLE="DevOps Engineer"

echo "Hello, I am $NAME and I am a $ROLE"

Run:

chmod +x variables.sh
./variables.sh

Output:

Hello, I am Alex and I am a DevOps Engineer

Single vs Double Quotes:

echo '$NAME'  → prints literal text $NAME  
echo "$NAME"  → prints the value of the variable

------------------------------------------------------------

## Task 3 – User Input with read

File: greet.sh

Script:

#!/bin/bash

read -p "Enter your name: " NAME
read -p "Enter your favourite tool: " TOOL

echo "Hello $NAME, your favourite tool is $TOOL"

Run:

chmod +x greet.sh
./greet.sh

Example output:

Enter your name: Alex  
Enter your favourite tool: Docker  
Hello Alex, your favourite tool is Docker

------------------------------------------------------------

## Task 4 – If-Else Conditions

File: check_number.sh

Script:

#!/bin/bash

read -p "Enter a number: " NUM

if [ $NUM -gt 0 ]; then
  echo "Number is positive"
elif [ $NUM -lt 0 ]; then
  echo "Number is negative"
else
  echo "Number is zero"
fi

------------------------------------------------------------

File: file_check.sh

Script:

#!/bin/bash

read -p "Enter filename: " FILE

if [ -f "$FILE" ]; then
  echo "File exists."
else
  echo "File does not exist."
fi

------------------------------------------------------------

## Task 5 – Server Check Script

File: server_check.sh

Script:

#!/bin/bash

SERVICE="sshd"

read -p "Do you want to check the status of $SERVICE? (y/n): " CHOICE

if [ "$CHOICE" = "y" ]; then
    systemctl is-active $SERVICE
    if [ $? -eq 0 ]; then
        echo "$SERVICE is running."
    else
        echo "$SERVICE is not running."
    fi
else
    echo "Skipped."
fi

------------------------------------------------------------

## What I Learned

Shell scripts automation ke liye bahut powerful hote hain.  
Variables aur user input use karke scripts interactive ban sakti hain.  
If-else conditions use karke scripts me decision making implement ki ja sakti hai.
