#!/bin/bash
set -e

cd infra || exit
IP=$(terraform output -raw public_ip)

cd ../ansible
printf "[web]\n%s ansible_user=ubuntu ansible_ssh_private_key_file=%s\n" \
  "$IP" "$HOME/.ssh/devops.pem" > inventory.ini

ansible-playbook -i inventory.ini playbook.yml
