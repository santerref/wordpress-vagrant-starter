# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"

  # Forwarded port mapping
  config.vm.network "private_network", ip: "10.0.0.55"
  config.vm.hostname = "example.dev"

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  # config.hostmanager.aliases = %w(sub.example.dev)

  config.vm.synced_folder ".", "/vagrant", :nfs => { :mount_options => ["dmode=775","fmode=664"] }
  config.vm.provision "shell", path: "provision/install.sh", args: [config.vm.hostname, "WordPress Site Title"]
end
