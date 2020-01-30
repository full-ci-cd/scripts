#!/bin/bash 

if [[ "$1" != "-u" ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then

	echo -e "Usage:\n\t -u <USER> [OPTIONS] \n\n\n[OPTIONS]\n   -r  - to delete users images\n   -s  - do use soft mode (ansible playbooks will not be applies)\n\t " && exit 0

fi


##Ubuntu OPTIONS
DOCKER_UBUNTU_RUN_CUSTOM_OPTIONS="--tmpfs=/run --tmpfs=/run/lock -v /sys/fs/cgroup/systemd:/sys/fs/cgroup/systemd --stop-signal=SIGRTMIN+3"
DOCKER_UBUNTU_RUN_CUSTOM_COMMAND="/sbin/init"

##Centos OPTIONS
DOCKER_CENTOS_RUN_CUSTOM_OPTIONS="--privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro"
DOCKER_CENTOS_RUN_CUSTOM_COMMAND="/usr/sbin/init"

##Vars used in GETOPTS  
NAME="null"
CHECKER_SOFT_MODE="no"


while getopts ":u:rs"  arg; do
	case $arg in 
		r)
                        if [[ "$(docker ps -a | grep $NAME | wc -l)" == "0" ]];then echo "nothing to delete" && exit 1 
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
                s)      
                        CHECKER_SOFT_MODE="yes"
			;;
	esac
done

##Check if containers exists
if [[ "$(docker ps -a | grep $NAME | wc -l )" == "0" ]];then 

	## starting docker containers
	docker run -ti $(echo $DOCKER_CENTOS_RUN_CUSTOM_OPTIONS) --name master_a_$(echo "$NAME")  -d -p "$(shuf -i 2000-65000 -n 1 )":22 fullcicd/common_centos:0.1.4 $DOCKER_CENTOS_RUN_CUSTOM_COMMAND
	docker run -ti $(echo $DOCKER_UBUNTU_RUN_CUSTOM_OPTIONS) --name master_j_$(echo "$NAME")  -d -p "$(shuf -i 2000-65000 -n 1 )":22 fullcicd/common_ubuntu:0.1.3 $DOCKER_UBUNTU_RUN_CUSTOM_COMMAND
	docker run -ti $(echo $DOCKER_CENTOS_RUN_CUSTOM_OPTIONS) --name kube-01_$(echo "$NAME")  -d -p "$(shuf -i 2000-65000 -n 1 )":22 fullcicd/common_centos:0.1.4 $DOCKER_CENTOS_RUN_CUSTOM_COMMAND

	if [[ "$(echo $CHECKER_SOFT_MODE)" == "no" ]];then
  		## applying ansible states
		ansible-playbook -i ../ansible_repo/hosts_test_$(echo "$NAME") ../ansible_repo/initial_configuration_playbook -vvv
	fi

else echo "containers of user already are declared" && exit 0
fi







