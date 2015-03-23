# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "harness", primary: true do |machine|
    machine.vm.box = "ubuntu/trusty64"
    machine.vm.hostname = "harness"
    machine.vm.network :private_network, ip: "10.1.0.2",
                       :netmask => "255.255.0.0"
    machine.vm.provider :virtualbox do |v| 
      v.customize ["modifyvm", :id, "--memory", 2048]
    end

    machine.vm.provision "ansible" do |ansible|
      ansible.playbook = "provisioning/getreqs.yml"
      ansible.limit = 'all'
    end

    machine.vm.provision "ansible" do |ansible|
      ansible.playbook = "provisioning/deploy.yml"
      ansible.groups = {
        "controller" => ["harness"],
        "network" => ["harness"],
        "compute" => ["harness"]
      }
      ansible.extra_vars = {
        openstack_controller_ip: "10.1.0.2",
        openstack_compute_node_ip: "10.1.0.2",
        openstack_network_node_ip: "10.1.0.2",
        openstack_network_external_device: "eth1",
        openstack_network_external_network: "10.1.0.0/16",
        openstack_network_external_gateway: "10.1.0.2",
        openstack_network_external_allocation_pool_start: "10.1.0.100",
        openstack_network_external_allocation_pool_end: "10.1.0.200",
        openstack_network_external_dns_servers: "8.8.8.8"
      }
      ansible.limit = 'all'
    end

    #machine.vm.provision "ansible" do |ansible|
    #  ansible.playbook = "provisioning/test.yml"
    #  ansible.groups = {
    #    "controller" => ["controller"],
    #    "network" => ["network"],
    #    "compute" => ["compute-001"]
    #  }
    #  ansible.limit = 'all'
    #end

  end

end
