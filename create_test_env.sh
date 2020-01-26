#!/bin/bash

if [[ "$1" == "-r" ]]; then docker rm -f $(docker ps -aq);fi

docker run -ti --name master_a -d -p 5001:22 fullcicd/common_centos:0.1.3
docker run -ti --name master_j -d -p 5004:22 fullcicd/common_ubuntu:0.1.3
#docker run -ti --name kube-01 -d -p 5002:22 fullcicd/common_centos:0.1.3
docker run -ti --name kube-01 -d -p 5002:22 fullcicd/common_centos:0.1.3

ansible-playbook -i ../ansible_repo/hosts_test ../ansible_repo/initial_configuration_playbook -vvv


#applying ansible states







