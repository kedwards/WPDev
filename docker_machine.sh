#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# enable interruption signal handling
trap - INT TERM

SCRIPT_DIR=$(dirname $(readlink -f "$0"))
SCRIPT_NAME=$(basename $(readlink -nf $0) ".sh")

opts=':b:h'

show_help()
{
    cat << EOF
Usage: ${SCRIPT_NAME}.sh -b box_name
Run the installer, with following options:
    -b  box name
    -h  prints this help message
EOF
}

OPTIND=1
while getopts ${opts} opt
do
    case "$opt" in
      b)  BOX=${OPTARG}
          ;;
      h)  show_help
          exit 1
          ;;
      \?)		# unknown flag
      	  show_help
	  	    exit 1
          ;;
    esac
done

shift $(($OPTIND - 1))

SSH_KEY=$(vagrant ssh-config ${BOX} | grep IdentityFile | awk '{print $2}' 2> /dev/null)
IP_ADDR=$(vagrant ssh ${BOX} -c "hostname -I | cut -d' ' -f2" 2> /dev/null)
PORT=$(vagrant ssh-config ${BOX} | grep Port | cut -d' ' -f4)

# docker-machine create -d generic --generic-ip-address ${IP_ADDR} --generic-ssh-port 22 --generic-ssh-key ~/.vagrant.d/insecure_private_key --generic-ssh-user vagrant ${BOX}
docker-machine create -d generic --generic-ip-address 10.10.10.10 --generic-ssh-port 22 --generic-ssh-key ~/.ssh/id_rsa --generic-ssh-user vagrant ${BOX}
