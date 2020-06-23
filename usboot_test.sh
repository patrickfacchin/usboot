#!/bin/bash
. src/printings.sh

USB_PREFIX=sdd
USB_PATH=/dev/"$USB_PREFIX"1
USB_MOUNT=/media/usboot
UUID=`blkid | grep "${USB_PREFIX}1" | sed -n 's/.*\sUUID=\"\([^\"]*\)\".*/\1/p'`
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
    sed -i "s/%uuid%/$UUID/g" $USB_MOUNT/boot/grub/grub.cfg

    print_msg "Removendo vm"
    VBoxManage unregistervm usboot --delete
    vboxmanage closemedium disk ./usboot.vdi --delete
    
    print_msg "VBOX: criando vmdk ..."
    VBoxManage internalcommands createrawvmdk -filename ./usboot.vmdk -rawdisk /dev/$USB_PREFIX

    print_msg "VBOX: criando vdi ..."
    VBoxManage createhd --filename ./usboot.vdi --size 512

    print_msg "VBOX: criando vm ..."
    VBoxManage createvm --name usboot --ostype 'Linux_64' --register

    print_msg "VBOX: criando ide controller ..."
    VBoxManage storagectl usboot --name 'IDE Controller' --add ide

    print_msg "VBOX: vinculando vmdk a ide controller..."
    VBoxManage storageattach usboot --storagectl 'IDE Controller' --port 0 --device 0 --type hdd --medium ./usboot.vmdk

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
