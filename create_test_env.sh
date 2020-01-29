#!/bin/bash

if [[ "$1" != "-u" ]]; then
	echo -e "Usage:\n\t -u <USER> -r (-r to delete, is optional to define if containers of <USER> should be created or deleted )\n\t " && exit 0
fi


NAME="null"

while getopts ":u::r"  arg; do
	case $arg in 
		r)      if [[ "$(docker ps -a | grep $NAME | wc -l)" == "0" ]];then echo "nothing to delete" &&  exit 1 
			else docker rm -f $(docker ps -a | grep $NAME | awk '{ print $1}' ) && exit 1
			fi
			;;
		u) 
			if [[ "$(echo $OPTARG)" == "robert" ]];then
				NAME="$(echo $OPTARG)" && echo "robert ----------------"
			elif [[ "$(echo $OPTARG)" == "przemek" ]];then
				NAME="$(echo $OPTARG)" && echo "przemek ---------------"
			else echo "zly parametr <przemek/robert>" && exit 1
			fi
			;;
			
	esac
done


if [[ "$(docker ps -a | grep $NAME | wc -l )" == "0" ]];then 
## starting docker containers
	docker run -ti --name master_a_$(echo "$NAME")  -d -p "$(shuf -i 2000-65000 -n 1 )":22 fullcicd/common_centos:0.1.4
	docker run -ti --name master_j_$(echo "$NAME")  -d -p "$(shuf -i 2000-65000 -n 1 )":22 fullcicd/common_ubuntu:0.1.3
	docker run -ti --name kube-01_$(echo "$NAME")  -d -p "$(shuf -i 2000-65000 -n 1 )":22 fullcicd/common_centos:0.1.4
## applying ansible states
	ansible-playbook -i ../ansible_repo/hosts_test_$(echo "$NAME") ../ansible_repo/initial_configuration_playbook -vvv
else echo "containers of user already are declared" && exit 0
fi







