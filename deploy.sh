#!/bin/bash
set -e

cd infra

APP_IP=$(terraform output -raw instance_public_ip)
SONAR_IP=$(terraform output -raw sonar_public_ip)

cd ../ansible

printf "[web]\n%s ansible_user=ubuntu ansible_ssh_private_key_file=%s\n\n[sonarqube]\n%s ansible_user=ubuntu ansible_ssh_private_key_file=%s\n" \
  "$APP_IP" "$HOME/.ssh/devops.pem" \
  "$SONAR_IP" "$HOME/.ssh/devops.pem" > inventory.ini

ansible-playbook \
  -i inventory.ini \
  sonarqube.yml \
  --ask-vault-pass

ansible-playbook -i inventory.ini playbook.yml
