# Multi purpose automation, easy lab setup, fast service deploy

## IaC: Auto deploy virtual resources. Currently libvirt.

``` bash
# Deploy a VM, you will be prompted for options, change vmname to you needs
./scripts/spin.sh vmname
```

## Ansible playbooks: os automation, (Kubernetes cluster example)

Spining a VM, and auto deploy kubernetes master node (control plane)
``` bash
# spin a VM
./scripts/spin.sh master
# Apply kubernetes master auto deploy playbook
./scripts/playbooks master kubernetes/master
# Connect to master via SSH
ssh cloud-user@masterip
# inside the VM shell
sudo su
cd
kubectl apply -f calico.yaml
kubeadm token create --print-join-command # to print node join command
```

Spining a worker node (data plane)
``` bash
# spin a VM
./scripts/spin.sh worker

# Apply kubernetes worker auto deploy playbook
./scripts/playbooks master kubernetes/master

# Connect to node via SSH
ssh cloud-user@nodeip

# Change this depending on the output of "kubeadm token create --print-join-command" command on master. add sudo before.
sudo kubeadm join 192.168.124.175:6443 --token stx5d1.thp43hisfqd329je --discovery-token-ca-cert-hash sha256:6a102bd4686cc9115d5f2d8826940a92f7ed597a2992b3f8e602b6c9fc0b5df9
```

On the master node you can do the following command to show nodes

``` bash
root@master:~# kubectl get nodes
NAME     STATUS   ROLES           AGE     VERSION
master   Ready    control-plane   8m15s   v1.28.12
worker   Ready    <none>          11s     v1.28.12
```
