# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "ubuntu/trusty64"
  config.vm.network :private_network, ip: "10.1.0.2", :netmask => "255.255.0.0"
  config.vm.network :forwarded_port, guest: 80, host: 8080 
  config.vm.network :forwarded_port, guest: 443, host: 8443 
  config.vm.network :forwarded_port, guest: 8888, host: 8888 
  config.vm.network :forwarded_port, guest: 56789, host: 56789

  config.vm.provider :virtualbox do |v|
    v.memory = 2048
    v.customize ["modifyvm", :id, "--nicpromisc2", "allow-vms"]
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "vagrant.yml"
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "getreqs.yml"
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "deploy.yml"
    ansible.groups = {
      "controller" => ["default"],
      "network" => ["default"],
      "compute" => ["default"]
    }
    ansible.extra_vars = {
      openstack_network_external_device: "eth1",
      openstack_network_external_gateway: "10.1.0.2",
      harness_deployment_crs_url: "http://localhost:56789/status/",
      harness_deployment_conpaas_url: "https://localhost:8443/"
    }
  end

end
