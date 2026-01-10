#!/bin/bash
 
while true ; do
  if [ -e /dev/sdc ] && [ -e /dev/sdd ] && [ -e /dev/sde ] && [ -e /dev/sdf ] ; then
    echo "/dev/sd{c-f} exists."
    break
  else
    echo "/dev/sd{c-f} does not exist. waiting..."
    sleep 5
  fi
done
FILE="/etc/fstab"

#############################################################################################

echo "--------------"
echo  Format Disk 01
echo "--------------"
parted /dev/sdc --script mklabel gpt mkpart xfspart xfs 0% 100%
partprobe /dev/sdc
 
while true ; do
  if [ -e /dev/sdc ] ; then
    echo "/dev/sdc1 exists."
    break
  else
    echo "/dev/sdc1 does not exist. waiting..."
    partprobe /dev/sdc
    sleep 5
  fi
done

mkfs.xfs /dev/sdc1

#############################################################################################

echo "--------------"
echo  Format Disk 02
echo "--------------"
parted /dev/sdd --script mklabel gpt mkpart xfspart xfs 0% 100%
partprobe /dev/sdd
 
while true ; do
  if [ -e /dev/sdd ] ; then
    echo "/dev/sdd1 exists."
    break
  else
    echo "/dev/sdd1 does not exist. waiting..."
    partprobe /dev/sdd
    sleep 5
  fi
done
 
mkfs.xfs /dev/sdd1

#############################################################################################

echo "--------------"
echo  Format Disk 03
echo "--------------"
parted /dev/sde --script mklabel gpt mkpart xfspart xfs 0% 100%
partprobe /dev/sde
 
while true ; do
  if [ -e /dev/sde ] ; then
    echo "/dev/sde1 exists."
    break
  else
    echo "/dev/sde1 does not exist. waiting..."
    partprobe /dev/sde
    sleep 5
  fi
done
 
mkfs.xfs /dev/sde1

#############################################################################################

parted /dev/sdf --script mklabel gpt mkpart xfspart xfs 0% 100%
partprobe /dev/sdf
 
while true ; do
  if [ -e /dev/sdf ] ; then
    echo "/dev/sdf1 exists."
    break
  else
    echo "/dev/sdf1 does not exist. waiting..."
    partprobe /dev/sdf
    sleep 5
  fi
done
 
mkfs.xfs /dev/sdf1

#############################################################################################
 
echo "-----------------"
echo  Create Directory
echo "-----------------"
mkdir -p /mnt/disk01
mkdir -p /mnt/disk02
mkdir -p /mnt/disk03
mkdir -p /mnt/disk04

echo "-----------"
echo  Mount Disk
echo "-----------"
mount /dev/sdc1 /mnt/disk01
mount /dev/sdd1 /mnt/disk02
mount /dev/sde1 /mnt/disk03
mount /dev/sdf1 /mnt/disk04
 
echo "---------------"
echo  Populate fstab
echo "---------------"
sudo cp ${FILE} ${FILE}.bak
UUID1=$(sudo blkid -o value -s UUID /dev/sdc1)
UUID2=$(sudo blkid -o value -s UUID /dev/sdd1)
UUID3=$(sudo blkid -o value -s UUID /dev/sde1)
UUID4=$(sudo blkid -o value -s UUID /dev/sdf1)
echo "UUID=${UUID1} /mnt/disk01 xfs defaults,nofail,auto 0 2" >> ${FILE}
echo "UUID=${UUID2} /mnt/disk02 xfs defaults,nofail,auto 0 2" >> ${FILE}
echo "UUID=${UUID3} /mnt/disk03 xfs defaults,nofail,auto 0 2" >> ${FILE}
echo "UUID=${UUID4} /mnt/disk04 xfs defaults,nofail,auto 0 2" >> ${FILE}