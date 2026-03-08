#!/bin/bash


if [ $EUID -ne 0 ]; then 
	echo "plz login as root :"
	exit 1

else 
	echo "root is logged in : "
fi

PACKAGES=("nginx" "curl" "httpd" )

for pkg in "${PACKAGES[@]}"
do
	if rpm -q $pkg &> /dev/null ; then
		echo "$pkg is already installed : "
	else
		echo "$pkg is installing ..."
		sudo dnf install $pkg -y
	fi
done
