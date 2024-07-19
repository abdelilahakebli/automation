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
terraform destroy -state="$vmpath/terraform.tfstate" -var-file="$vmpath/terraform.tfvars"
rm -r $vmpath