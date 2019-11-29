#!/bin/bash
. src/printings.sh

if [ "$(id -u)" != "0" ]; then
   echo "# OPS! VOCÊ TEM QUE EXECUTAR SCRIPT COMO ROOT" 1>&2
   exit 1
fi

print_msg "Desmontando unidades USB"
for usb_dev in /dev/disk/by-id/usb-*; do
    dev=$(readlink -f $usb_dev)
    grep -q ^$dev /proc/mounts && umount $dev
done


cd docker
print_msg "Parando e removendo containers"
docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)

print_msg "Rodando build e subindo container do mesmo"
docker-compose up -d --build

print_msg "Acessando container e rodando script './usboot.sh'"
docker exec -it app_env ./usboot.sh
