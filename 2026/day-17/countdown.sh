#!/bin/bash

read -p "enter the number : " NUM

while [ $NUM -ge 0 ]
do
	echo $NUM
	NUM=$((NUM-1))
done

echo "DONE"

