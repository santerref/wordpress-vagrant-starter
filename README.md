Step to create new WordPress site
===

1. Install [Vagrant Host Manager plugin](https://github.com/devopsgroup-io/vagrant-hostmanager)
2. Modify hostname, aliases (if any) and static IP in `Vagrantfile`
3. Set WordPress site title in `Vagrantfile`
4. Set admin username, email and password in `povision/install.sh` at the end
5. Set hostname and aliases in `provision/nginx/sites-available/vhost`
6. `vagrant up`
