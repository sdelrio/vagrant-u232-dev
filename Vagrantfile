# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

DO_INSTALL=ENV['DO_INSTALL'] || 'false'
DO_CLEAN_WWW=ENV['DO_CLEAN_WWW'] || 'false'
DO_XBT=ENV['DO_XBT'] || 'false'
DO_GIT_REPO=ENV['DO_GIT_REPO'] || 'https://github.com/Bigjoos/U-232-V5.git'

install=String(DO_INSTALL)
xbt=String(DO_XBT)
cleanwww=String(DO_CLEAN_WWW)
gitrepo=String(DO_GIT_REPO)

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "u232"  do |u232|
      u232.vm.hostname = "u232v5.vagrant.vm"
      u232.vm.box_url = "https://atlas.hashicorp.com/ARTACK/boxes/debian-jessie"
      u232.vm.box = "ARTACK/debian-jessie"
      u232.vm.provider "virtualbox" do |vb|
            vb.customize ["modifyvm", :id, "--cpus", "1"]
            vb.customize ["modifyvm", :id, "--cpuexecutioncap", "100"]
            vb.customize ["modifyvm", :id, "--memory", "2048"]
            vb.customize ["modifyvm", :id, "--natnet1", "192.168.44/24"]
      end
      u232.vm.provision :shell, :path => "provision.sh", :args => "-i "+ install + " -x " + xbt + " -c " + cleanwww + " -g " + gitrepo
      #u232.vm.provision :shell, :path => "provision.sh", :args => "-install" + Integer(DO_INSTALL)
      u232.vm.network "forwarded_port", guest: 80, host: 8080
      if xbt == 'true'
        u232.vm.network "forwarded_port", guest: 2710, host: 2710, protocol: 'tcp'
        u232.vm.network "forwarded_port", guest: 2710, host: 2710, protocol: 'udp'
      end
      u232.vm.network "forwarded_port", guest: 8025, host: 8025 # mailhog web interface
      u232.vm.network "forwarded_port", guest: 1025, host: 1025 # mailhog smtp
      u232.vm.synced_folder "html", "/var/www/html", owner: "www-data", group: "www-data"
  end

# solo por si queremos entrar desde equipos de nuestra LAN sin tener que poner :8080 al final de la URL
# config.vm.network :public_network, bridge:, ip : "192.168.0.254"

end
