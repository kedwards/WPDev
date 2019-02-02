# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"

require 'yaml'

plugins_dependencies = %w(vagrant-aws vagrant-vbguest vagrant-hostsupdater)
plugin_status = false
plugins_dependencies.each do |plugin_name|
  unless Vagrant.has_plugin? plugin_name
    system("vagrant plugin install #{plugin_name}")
    plugin_status = true
    puts " #{plugin_name}  Dependencies installed"
  end
end
if plugin_status === true
  exec "vagrant #{ARGV.join" "}"
end

machines = YAML.load_file(File.join(File.dirname(__FILE__), 'machines.yml'))

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  machines.each_with_index do |machine, index|
    if machine['enabled'] == true
      config.vbguest.auto_update = false
      config.vm.box_check_update = false
      config.ssh.insert_key = false
      config.vm.synced_folder '.', '/vagrant', disabled: true
      config.vm.define machine['name'] do |srv|
        srv.vm.hostname = machine['name']

        case machine['type']
        when 'vb'
            srv.vm.network :private_network, ip: machine['ip_addr']
            srv.vm.provider :virtualbox do |vb, override|
              override.vm.box = machine['box']
              vb.memory = machine['ram']
              vb.cpus = machine['vcpu']
              vb.customize [
                "modifyvm", :id,
                "--nictype1", "virtio",
        	      "--natdnshostresolver1", "on",
              ]
            end

          when 'aws'
            srv.vm.provider :aws do |aws, override|
              override.vm.box = machine['box']
              aws.aws_dir = ENV['HOME'] + "/.aws/"
              aws.session_token = ENV['SESSION TOKEN']
              aws.access_key_id = ENV['AWS_ACCESS_KEY_ID']
              aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
              aws.region = ENV['AWS_DEFAULT_REGION']
              aws.keypair_name = machine['keypair_name']
              aws.instance_type = machine['instance_type']
              aws.subnet_id = machine['subnet_id']
              aws.security_groups = machine['security_group']
              aws.associate_public_ip = machine['associate_public_ip']
              aws.tenancy = "default"
              aws.tags = {
                'Name' => machine['tags']['name'],
                'Team' => machine['tags']['team']
              }
              aws.ami = machine['ami']
              override.ssh.username = "admin"
              override.ssh.private_key_path = machine['private_key_path']
          end
        end

        srv.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/authorized_keys"
        srv.ssh.private_key_path = ["~/.vagrant.d/insecure_private_key", "~/.ssh/id_rsa"]
        srv.ssh.insert_key = false

        config.trigger.after :up do |trigger|
          trigger.info = "Adding box to docker-machine"
          trigger.run = { inline: 'docker-machine create -d generic --generic-ip-address ' + machine['ip_addr'] + '--generic-ssh-port 22 --generic-ssh-key ~/.vagrant.d/insecure_provate_key --generic-ssh-user vagrant ' + machine['name']}
        end

        srv.vm.provision :vai do |ansible|
          ansible.inventory_dir='inventory/'
          ansible.inventory_filename='vagrant'
        end
      end
    end
  end
end
