sudo easy_install pip
sudo pip install paramiko PyYAML Jinja2 httplib2 six
git clone git://github.com/ansible/ansible.git --recursive
cd ./ansible
source ./hacking/env-setup
echo "127.0.0.1" > ~/ansible_hosts
export ANSIBLE_INVENTORY=~/ansible_hosts

# scp ~/.ssh/rsa_id.pub dbuchan@bioinfstageX:/home/dbuchan/.ssh/authorized_keys

# on target machines add
# dbuchan ALL=(ALL) NOPASSWD: ALL
# to visudo config

# ssh-agent bash
# ssh-add ~/.ssh/id_rsa
# switch to the relevant virtualenv
# source /scratch0/NOT_BACKED_UP/dbuchan/python2/bin/activate
# source /cs/research/bioinf/home1/green/dbuchan/ansible/hacking/env-setup
