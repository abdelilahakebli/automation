#!/bin/bash

homedir="/home/$USER"
projctdir="$homedir/SRE/tools"
tfpath="$projctdir/tf"
inventorypath="$projctdir/inventory"
playbooks="$projctdir/playbooks"
configpath="$projctdir/config"
imagespath="$projctdir/images"

vmpath="$inventorypath/$1"

cd $tfpath/libvirt-vm/

rm terraform.tfstate terraform.tfstate.backup
terraform apply -state-out="$vmpath/terraform.tfstate" "$vmpath/plan.out"
