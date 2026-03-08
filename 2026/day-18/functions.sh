#!/bin/bash

greet () {
        name=$1
	echo "Hello, $name!"
}

add () {
	num1=$1
	num2=$2
	sum=$((num1+num2))
	echo "SUM : $sum"
}

greet "Aniruddha"
add 6 10
