#!/bin/bash
if [ $# -ne 1 ]
then 
echo "anna masina nimi"
exit 1
fi

NAME=$1
VIRT_DIR="/var/lib/libvirt/images"
IMAGE=$VIRT_DIR/$NAME.img

echo "kustutan img faili $IMAGE"
rm $IMAGE
test -e ${VIRT_DIR}/${NAME}1.img && rm ${VIRT_DIR}/${NAME}1.img

echo "haltin virtuaalmasina $NAME"
virsh -c qemu:///system shutdown $NAME
