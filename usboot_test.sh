#!/bin/bash
. src/printings.sh

USB_PATH=/dev/sdb1
USB_MOUNT=/mnt/usboot

print_banner

if [ "$(id -u)" != "0" ]; then
   echo "# OPS! VOCÊ TEM QUE EXECUTAR SCRIPT COMO ROOT" 1>&2
   exit 1
fi

read -p "Deseja testar o USBOOT? (y/n):" -n 1 -r
echo # (opticional) mover para proxima linha
if [[ $REPLY =~ ^[Yy]$ ]]
then
    print_msg "Desmontando unidades USB"
    for usb_dev in /dev/disk/by-id/usb-*; do
        dev=$(readlink -f $usb_dev)
        grep -q ^$dev /proc/mounts && umount $dev
    done
    
    rm -rf $USB_MOUNT && mkdir -p $USB_MOUNT
            
    print_msg "Montando device..."
    mount $USB_PATH $USB_MOUNT

    print_msg "Atualizando grub.cfg"
    rm $USB_MOUNT/boot/grub/grub.cfg
    cp grub.cfg $USB_MOUNT/boot/grub/grub.cfg

    print_msg "Removendo vm"
    VBoxManage unregistervm usboot --delete
    rm $USB_MOUNT/usboot.vdi $USB_MOUNT/usboot.vmdk 
    rm -Rf /root/VirtualBox\ VMs/usboot

    print_msg "VBOX: criando vmdk ..."
    VBoxManage internalcommands createrawvmdk -filename $USB_MOUNT/usboot.vmdk -rawdisk /dev/sdb

    print_msg "VBOX: criando vdi ..."
    VBoxManage createhd --filename $USB_MOUNT/usboot.vdi --size 512

    print_msg "VBOX: criando vm ..."
    VBoxManage createvm --name usboot --ostype 'Linux_64' --register

    print_msg "VBOX: criando ide controller ..."
    VBoxManage storagectl usboot --name 'IDE Controller' --add ide

    print_msg "VBOX: vinculando vmdk a ide controller..."
    VBoxManage storageattach usboot --storagectl 'IDE Controller' --port 0 --device 0 --type hdd --medium $USB_MOUNT/usboot.vmdk

    print_msg "VBOX: modificando valores da vm ..."
    VBoxManage modifyvm usboot --boot1 disk --boot2 none --boot3 none --boot4 none
    VBoxManage modifyvm usboot --memory 1024 --vram 128
    VBoxManage modifyvm usboot --bioslogodisplaytime 1

    print_msg "VBOX: recarregando configurações..."
    umount -f $USB_MOUNT
    mount $USB_PATH $USB_MOUNT

    print_msg "VBOX: ligando vm ..."
    VBoxManage startvm usboot
fi
