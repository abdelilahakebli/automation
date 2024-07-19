#!/bin/bash

homedir="/home/$USER"
projctdir="$homedir/SRE/tools"
tfpath="$projctdir/tf"
inventorypath="$projctdir/inventory"
playbooks="$projctdir/playbooks"
configpath="$projctdir/config"
imagespath="$projctdir/images"

username="cloud-user"
ssh_private_key="$homedir/.ssh/id_ed25519"
ssh_public_key="$homedir/.ssh/id_ed25519.pub"

vmpath="${inventorypath}/$1"
inv_file="$vmpath/inventory.ini"
playbook="${playbooks}/$2.yml"
ansible-playbook -u $username --private-key $ssh_private_key -i $inv_file $playbook
