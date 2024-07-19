#!/bin/bash

homedir="/home/$USER"
projctdir="$homedir/SRE/tools"
tfpath="$projctdir/tf"
inventorypath="$projctdir/inventory"
playbooks="$projctdir/playbooks"
configpath="$projctdir/config"
imagespath="$projctdir/images"



provider="libvirt"
cloud_image=""
vcpu=1
ram=512
disk="4G"
hostname="$1"
username="cloud-user"

# Change SSH Keys
ssh_private_key="$homedir/.ssh/id_ed25519"
ssh_public_key="$homedir/.ssh/id_ed25519.pub"

cloud_init="$configpath/default_cloud_init.yml"
network_init="$configpath/default_netplan_init.yml"


search_and_select_image() {
    clear
    local folder="$1"
    local images=()

    # Search for image files in the specified folder
    while IFS= read -r -d '' file; do
        images+=("$file")
    done < <(find "$folder" -type f \( -name "*.img" -o -name "*.qcow2" -o -name "*.iso" \) -print0)

    # Check if any images were found
    if [ ${#images[@]} -eq 0 ]; then
        echo "No cloud image files found in the specified folder."
        return 1
    fi

    # List the found images
    echo "Select a cloud image file:"
    for i in "${!images[@]}"; do
        echo "$((i + 1))) $(basename "${images[$i]}")"
    done

    # echo "Or enter a URL to download a cloud image:"
    read -p "Enter your choice (number or URL): " choice

    if [[ $choice =~ ^[0-9]+$ ]] && [ "$choice" -gt 0 ] && [ "$choice" -le "${#images[@]}" ]; then
        selected_image="${images[$((choice - 1))]}"
        echo "You selected: $selected_image"
        declare -g cloud_image="$( readlink -m $selected_image)"
    else
        echo "Downloading the image from the url."
        # Add your download command here, e.g.:
        wget -P "$folder" "$choice"
        search_and_select_image "../cloud-images"
    fi
}




search_and_select_image $imagespath


echo "Resources:"
# read -p "vcpu (max $(nproc)): " vcpu
# read -p "ram   (max $(free -h | grep Mem | awk '{print ($7) }')): " ram
read -p "vcpu (2 core): " vcpu
read -p "ram (2048 MB): " ram
read -p "disk (16 GB): " disk

if test -z "$vcpu"
    then
        vcpu=2
fi

if test -z "$ram"
    then
        ram=2048
fi

if test -z "$disk"
    then
        disk="16G"
fi


clear
echo "Metadata"
defaultvmname="vm-$(openssl rand -hex 2)"
read -p "user  (cloud-user):" username


# ssh_key="$( readlink -m $ssh_key)"
if test -z "$username"
    then
        username="cloud-user"
fi

clear
echo "provider: $provider"
echo "image   : $cloud_image"
echo "vcpu    : $vcpu"
echo "ram     : $ram"
echo "disk    : $disk"
echo "hostname: $hostname"
echo "username: $username"
echo "ssh key : $ssh_key"
echo "cloud-init: $cloud_init"
echo "network-init: $network_init"



vmpath="$inventorypath/$hostname"
mkdir -p $vmpath

echo "Making Qcow2 image..."
cp $cloud_image $vmpath/

cloud_image="$vmpath/$(basename $cloud_image )"

qemu-img resize $cloud_image $disk

tfvarsfile="$hostname.tfvars.lck"
tfvarsfile="$( readlink -m $tfvarsfile)"

echo "vm_name = \"$hostname\"" > $tfvarsfile
echo "vm_memory = \"$ram\"" >> $tfvarsfile
echo "vm_vcpu = \"$vcpu\"" >> $tfvarsfile
echo "image_source = \"$cloud_image\"" >> $tfvarsfile

echo "ssh_username = \"$username\"" >> $tfvarsfile
echo "ssh_key_public = \"$ssh_public_key\"" >> $tfvarsfile
echo "ssh_key_private = \"$ssh_private_key\"" >> $tfvarsfile

echo "cloud_init_config = \"$cloud_init\"" >> $tfvarsfile
echo "network_init_config = \"$network_init\"" >> $tfvarsfile

echo "playbooks_path = \"$playbooks\"" >> $tfvarsfile
echo "vm_path = \"$vmpath\"" >> $tfvarsfile


# echo "ansible_path = \"$ansible_path\"" >> $tfvarsfile

tfvarsfile="$( readlink -m $tfvarsfile)"


# terraform -chdir="$tfpath/libvirt-spin-vm" apply -var-file="$tfvarsfile" -auto-approve




mv $tfvarsfile "$vmpath/terraform.tfvars"
cp $cloud_init "$vmpath/cloud_init.cfg"
cp $network_init "$vmpath/network_init.yml"

echo "Applying changes..."
cd $tfpath/libvirt-vm/
terraform plan -out="$vmpath/plan.tfplan" -var-file="$vmpath/terraform.tfvars"
terraform apply -state-out="$vmpath/terraform.tfstate" "$vmpath/plan.tfplan"

echo "Removing cloned image..."
rm $cloud_image
