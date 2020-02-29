#!/bin/bash

#Determine OS and install method

if [ -f  /etc/centos-release ]; then
	kinstall="yum"
	cat /etc/centos-release
fi


if [ -f /etc/issue ]; then
	kinstall="apt-get"
	cat /etc/issue
fi



if [ -e /usr/bin/docker ]; then

    echo "Docker is already installed"
    docker --version
    echo " "
else
    echo "installing docker" 
    #sudo $kinstall  update -y
    #sudo $kinstall install -y docker
    #sudo service docker start
    #sudo usermod -a G docker centos
    echo "done"
fi

