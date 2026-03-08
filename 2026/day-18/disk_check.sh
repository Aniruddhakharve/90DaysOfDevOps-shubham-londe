#!/bin/bash


check_disk (){
echo "Disk Usage: "
df -h /
}

check_memory(){
echo "Memory usage:"
free -h
}

check_disk
echo "-----------------------"
check_memory
