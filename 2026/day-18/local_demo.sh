#!/bin/bash

demo_local() {
local VAR="Inside the Function"
echo "Local Variable : $VAR"
}

demo_global() {
VAR="Global Variable"
}

demo_local 
echo "Outside function VAR : ${VAR:-Not Set}"

demo_global
echo "Ouside the function after global assignment: $VAR "
