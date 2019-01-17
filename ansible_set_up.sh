# sudo easy_install pip
# sudo pip install paramiko PyYAML Jinja2 httplib2 six
# git clone git://github.com/ansible/ansible.git --recursive
# cd ./ansible
# source ./hacking/env-setup
# echo "127.0.0.1" > ~/ansible_hosts
# export ANSIBLE_INVENTORY=~/ansible_hosts

# ssh-keygen -t rsa
# ensure /home/dbuchan/.ssh exists on target machine
# scp ~/.ssh/id_rsa.pub dbuchan@bioinfstageX:/home/dbuchan/.ssh/authorized_keys
# on target machines add
# dbuchan ALL=(ALL) NOPASSWD: ALL
# to visudo config
# make sure this is saved correctly after reboot

ssh-agent bash
ssh-add ~/.ssh/id_rsa
# switch to the relevant virtualenv
source /scratch0/NOT_BACKED_UP/dbuchan/python2/bin/activate
source /home/dbuchan/Applications/ansible/hacking/env-setup

# ./Everything
#ansible-playbook -i -K staging deploy_staging.yml

# webservices
# ansible-playbook -i -K staging restart_aa.yml
