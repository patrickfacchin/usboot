#!/bin/bash
. src/printings.sh

USB_PREFIX=sdd
USB_PATH=/dev/"$USB_PREFIX"1
USB_MOUNT=/media/usboot
ISO_FILE=xubuntu-18.04.4-desktop-amd64.iso
ISO_URL=http://www.mirrorservice.org/sites/cdimage.ubuntu.com/cdimage/xubuntu/releases/18.04/release/
UUID=`blkid | grep "${USB_PREFIX}1" | sed -n 's/.*\sUUID=\"\([^\"]*\)\".*/\1/p'`

# lsblk -o NAME,SIZE 
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

    umount /mnt
    rm -rf $USB_MOUNT && mkdir -p $USB_MOUNT
            
    print_msg "Formatando device ..."
    sgdisk --zap-all /dev/$USB_PREFIX
    sgdisk --new=1:0:0 --typecode=1:ef00 /dev/$USB_PREFIX
    mkntfs -L GRUB2EFI /dev/"$USB_PREFIX"1
    # mkfs.exfat -i DAT -n GRUB2EFI /dev/"$USB_PREFIX"1
    # mkfs.vfat -F32 -n GRUB2EFI /dev/"$USB_PREFIX"1
    
    print_msg "Montando device..."
    mount $USB_PATH $USB_MOUNT

    

    print_msg "Instalando grub..."
    grub-install --force --no-floppy --root-directory=$USB_MOUNT /dev/$USB_PREFIX
    
    print_msg "Atualizando grub.cfg"
    cp grub.cfg $USB_MOUNT/boot/grub/grub.cfg
    sed -i "s/%uuid%/$UUID/g" $USB_MOUNT/boot/grub/grub.cfg
    
    print_msg "Inicializando pasta de isos..."
    mkdir -p $USB_MOUNT/isos

    print_msg "Inicializando download de iso..."
    # axel -n 10 $ISO_URL$ISO_FILE

    print_msg "Movendo isos para a pasta de isos..."
    pv $ISO_FILE > $USB_MOUNT/isos/$ISO_FILE
    # pv Win10_2004_EnglishInternational_x64.iso > $USB_MOUNT/isos/Win10_2004_EnglishInternational_x64.iso

    print_msg "Montando win10..."
    mount ./Win10_2004_EnglishInternational_x64.iso /mnt -o loop

    echo "Copiando arquivos do Windows ..."
    cp -r /mnt/* $USB_MOUNT
fi
