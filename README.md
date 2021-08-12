# Deploying Staging
deploy_staging.yml is an ansible playbook. It allows you to communicate with the staging machines from your command machine remotely, updating them. It is used to allow changes to the psipred website to be checked before they go into production.

ansible_config is not a final repository, rather it is a living document that both describes how the servers are set up, and enables you to change them.

# Gotchas

## secure access
ansible and git both rely on secure access to servers, which means that passwords must be pushed around the system.
These secrets are not saved on github - you will have to request a tarball and then add the files to the secrets folder in ansible_config.

staging_secrets.yaml includes the passwords for the different users. You should modify the final section - 'your credentials'
These provide your github credentials and also your credentials when logging onto the servers.
You need two lines:
```
username_password: <this is your github login name>:<this is a github token >
```
Your github token must have full scope for private repos, so that
you can download blast_cache.
```
user: <your user name on the staging machines>
```
## lack of space
bioinfstage3 is tight on space so if it runs out it is worth removing rpm files from /var/cache/yum/x86_64/7/updates/packages
clear_out.sh will do that.


### passwordless ssh
You must be able to ssh into the desired machines without using a password.
This is straight forward using the guide [here](https://linuxize.com/post/how-to-setup-passwordless-ssh-login/).

Check that you can reach all the machines needed for staging. You should either do this by being on a UCL machine or by logging into Sonic Connect or equivalent from whence you can get to the staging servers.


## working in python3.6
The servers are currently operating python 3.6 which may not be the same as
the python version on the master machine. This may mean that requirements which work on the master machine then fail on the servers.
To get round this it is worth developing the requirements using pyenv (which allows you to shift python version from project to project).
Instructions for installing pyenv are [here] (https://github.com/pyenv/pyenv#installation) and virtualenv (similar to conda or pipenv in that it makes virtual environments - but works well with pyenv) in tandem. Virtualenv and virtualenvwrapper are installed with pip. This is also necessary to use the automatic start up in utility scripts.

## Structure
The roles directory sets out the tasks for each of the roles, with the following directory structure:

 - roles
    - restart_webserver
        - tasks
            - main.yml
    - other roles.

The meat of the work is done in these main.yml files.

Most of the tasks should be commented out, so it will be necessary to uncomment those that need to be changed.

for example, if I have modified analytics_automated then I would push the new code to github, and then search for just those roles which pull the code using

```
grep -rn . -e analytics_automated.git
```

Then go into those roles and uncomment just those tasks which are affected by the new pull.

This will include at least:

- pulling the files themselves
- copying over data from ansible_config to the newly copied file structure
- running the django commands if you are pulling the webserver etc.

easy_add_remove_hash.ipynb is a jupyter notebook which will easily add and remove hashtags
for the lazy.

## Finally

Start a suitable virtual environment and install ansible.

```
pyenv global 3.6.8
mkvirtualenv ansible
pip install ansible
workon ansible
ansible all -i <staging file> -m ping -u <your username on the remote machines>
```
here the flag -i points to the inventory staging - in practice a list of machines that will be called
for the different plays. see [here][https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html]

deploy_staging.yml is the name of the playbook

-u swooller is the username on the server

-vv verbose
