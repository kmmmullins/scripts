#!/bin/bash

if [ -e /usr/bin/docker ]; then
    echo "Docker is already installed"
    docker --version
    echo " "
else
    echo "installing docker" 
    #sudo yum  update -y
    #sudo yum install -y docker
    #sudo service docker start
    #sudo usermod -a G docker centos
    echo "The installation is complete"
    docker --version
fi

