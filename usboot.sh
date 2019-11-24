#!/bin/bash
. src/printings.sh

USB_PATH=/dev/sdb1
USB_MOUNT=/mnt/usboot
#ISO_FILE=ubuntu-18.04.3-desktop-amd64.iso
#ISO_URL=http://releases.ubuntu.com/18.04/
ISO_FILE=xubuntu-18.04-desktop-amd64.iso 
ISO_URL=http://www.mirrorservice.org/sites/cdimage.ubuntu.com/cdimage/xubuntu/releases/18.04/release/


print_banner

if [ "$(id -u)" != "0" ]; then
   echo "# OPS! VOCÊ TEM QUE EXECUTAR SCRIPT COMO ROOT" 1>&2
   exit 1
fi

read -p "Deseja criar o USBOOT? (y/n):" -n 1 -r
echo # (opticional) mover para proxima linha
if [[ $REPLY =~ ^[Yy]$ ]]
then
    print_msg "Desmontando unidades USB"
    for usb_dev in /dev/disk/by-id/usb-*; do
        dev=$(readlink -f $usb_dev)
        grep -q ^$dev /proc/mounts && umount $dev
    done

    rm -rf $USB_MOUNT && mkdir -p $USB_MOUNT
            
    print_msg "Formatando device em ext4 ..."
    sgdisk --zap-all /dev/sdb
    sgdisk --new=1:0:0 --typecode=1:ef00 /dev/sdb
    mkfs.vfat -F32 -n GRUB2EFI /dev/sdb1
    
    print_msg "Montando device..."
    mount $USB_PATH $USB_MOUNT

    print_msg "Instalando grub..."
    grub-install --force --no-floppy --root-directory=$USB_MOUNT /dev/sdb
    
    print_msg "Inicializando pasta de isos..."
    mkdir -p $USB_MOUNT/isos

    print_msg "Inicializando download de iso..."
    axel -n 10 $ISO_URL$ISO_FILE

    print_msg "Movendo iso para a pasta de isos..."
    pv $ISO_FILE > $USB_MOUNT/isos/$ISO_FILE

fi
