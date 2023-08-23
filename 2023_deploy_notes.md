# Things to keep track of for the upcoming production deploy

1. Turn off/move the old httpd/djanog process on bioinf1
2. Remove any portforwarding rules that the old system needed
3. Installing s4pred
4. bioinf3 update python and update the A_A virtualenv
5. bm2 and bm3, update python and update the A_A virtualenv



## Fixing the repo list:

Yum repo list error
https://stackoverflow.com/questions/60648390/how-to-remove-rpmdb-failed-release-provides

`Cannot find a valid baseurl for repo: base/$releasever/x86_64`

`cat /etc/centos-release`
machine is on centos 7.9.2009
These repos @ http://vault.centos.org/7.9.2009 are archived. 

Need to change to mirror.centos.org in 
/etc/yum.repos.d/CentOS-Vault.repo and /etc/yum.repos.d/CentOS-Sources.repo

1. in CentOS-Base.repo swap mirrorlist for baseurl and set $releasever to 7.9.2009

## Updating python 

As root build and install python3.9 with shared libs
``` bash
sudo su
cd ~
wget https://www.python.org/ftp/python/3.9.17/Python-3.9.17.tgz 
tar -zxvf Python-3.9.17.tgz
cd Python-3.9.17/
./configure --prefix=/usr --enable-shared LDFLAGS="-Wl,-rpath /usr/lib"
make; make install
ldconfig
```

As the aa head user install the depenencies, probably comment out the mod-wsgi and mod-wsgi-httpd versions
``` bash
cd /opt/aa_httpd
apachectl stop
su django_aa
pip3.9 install --upgrade virtualenv
cd ~
mv aa_env aa_env_old
virtualenv aa_env -p /bin/python3.9
source ~/aa_env/bin/activate
cd analytics_automated
pip install "setuptools<58.0.0"
vi requirements/base.txt
pip install -r requirements/staging.txt

``` 

As a worker install the bits
probably comment out the mod-wsgi and mod-wsgi-httpd versions
``` bash
su django_worker
cd ~ 
source ~/aa_env/bin/activate
cd analytics_automated
celery multi stop_verify worker --pidfile=/home/django_worker/analytics_automated/celery.pid --logfile=/home/django_worker/analytics_automated/logs/ 
cd ../
mv aa_env aa_env_old
virtualenv aa_env -p /bin/python3.9
source ~/aa_env/bin/activate
cd analytics_automated
pip install "setuptools<58.0.0"
vi requirements/base.txt
pip install -r requirements/staging.txt
celery --app=analytics_automated_project.celery:app worker --loglevel=INFO -Q low_localhost,localhost,high_localhost,celery,low_R,R,high_R,low_Python,Python,high_Python --pidfile=celery.pid --detach
```