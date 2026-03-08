#!/bin/bash

if [ -z "$1" ]; then
	echo " usage : ./greet.sh <name> "
else
	echo " hello , $1!"
fi
