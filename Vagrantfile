# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.ssh.insert_key = false

  config.vm.define "compute-001", autostart: false do |m|
    m.vm.box = "ubuntu/trusty64"
    m.vm.hostname = "compute-001"
    m.vm.network :private_network, ip: "10.1.0.3", :netmask => "255.255.0.0"
    m.vm.provider :virtualbox do |v|
      v.memory = 1280
    end
  end

  config.vm.define "compute-002", autostart: false do |m|
    m.vm.box = "ubuntu/trusty64"
    m.vm.hostname = "compute-002"
    m.vm.network :private_network, ip: "10.1.0.4", :netmask => "255.255.0.0"
    m.vm.provider :virtualbox do |v|
      v.memory = 1280
    end
  end

  config.vm.define "compute-003", autostart: false do |m|
    m.vm.box = "ubuntu/trusty64"
    m.vm.hostname = "compute-003"
    m.vm.network :private_network, ip: "10.1.0.5", :netmask => "255.255.0.0"
    m.vm.provider :virtualbox do |v|
      v.memory = 1280
    end
  end

  config.vm.define "compute-004", autostart: false do |m|
    m.vm.box = "ubuntu/trusty64"
    m.vm.hostname = "compute-004"
    m.vm.network :private_network, ip: "10.1.0.6", :netmask => "255.255.0.0"
    m.vm.provider :virtualbox do |v|
      v.memory = 1280
    end
  end

  config.vm.define "controller", primary: true do |m|
    m.vm.box = "ubuntu/trusty64"
    m.vm.hostname = "controller"
    m.vm.network :private_network, ip: "10.1.0.2", :netmask => "255.255.0.0"
    m.vm.network :forwarded_port, guest: 80, host: 8080 
    m.vm.network :forwarded_port, guest: 443, host: 8443 
    m.vm.network :forwarded_port, guest: 8888, host: 8888 
    m.vm.network :forwarded_port, guest: 56789, host: 56789

    m.vm.provider :virtualbox do |v|
      v.memory = 2048
      v.customize ["modifyvm", :id, "--nicpromisc2", "allow-vms"]
    end

    m.vm.provision "ansible" do |ansible|
      ansible.playbook = "vagrant.yml"
    end

    m.vm.provision "ansible" do |ansible|
      ansible.playbook = "getreqs.yml"
    end

    m.vm.provision "ansible" do |ansible|
      ansible.playbook = "deploy.yml"
      ansible.limit = "all"
      ansible.groups = {
        "controller" => ["controller"],
        "network" => ["controller"],
        "compute" => ["controller", "compute-001", "compute-002", "compute-003", 
                      "compute-004"]
      }
      ansible.extra_vars = {
        openstack_controller_ip: "10.1.0.2",
        openstack_network_external_device: "eth1",
        openstack_network_external_gateway: "10.1.0.2",
        harness_deployment_crs_url: "http://localhost:56789/status/",
        harness_deployment_conpaas_url: "https://localhost:8443/",
        openstack_compute_node_ip:
          "{{ ansible_all_ipv4_addresses|ipaddr('10.1.0.0/16')|first }}",
        openstack_network_local_ip:
          "{{ ansible_all_ipv4_addresses|ipaddr('10.1.0.0/16')|first }}"
      }
    end

  end

end
