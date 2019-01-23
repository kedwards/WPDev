# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"

require 'yaml'
machines = YAML.load_file(File.join(File.dirname(__FILE__), 'machines.yml'))

plugins_dependencies = %w(
  vagrant-aws
  vagrant-gatling-rsync
  vagrant-vbguest
  vagrant-hostsupdater
)
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

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box_check_update = false
  config.vbguest.auto_update = false
  config.gatling.latency = 2.5
  config.gatling.time_format = "%H:%M:%S"
  config.gatling.rsync_on_startup = false

  machines.each do |machine|
    if machine['enabled'] == true
      config.vm.define machine['name'] do |srv|
        srv.vm.hostname = machine['name']

        if machine['sync_disabled'] != nil
          srv.vm.synced_folder '.', '/vagrant', disabled: machine['sync_disabled']
        else
          srv.vm.synced_folder '.', '/vagrant', disabled: true
        end

        case machine['type']
          when "vb"
            File.open(machine['inventory'] = "/vagrant", 'w') do |f|
              f.write "[" + machine['name'] + "]\n"

              machine['nics'].each do |net|
                if net['ip_addr'] == 'dhcp'
                  srv.vm.network net['type'], type: net['ip_addr']
                else
                  srv.vm.network net['type'], ip: net['ip_addr']
                  f.write net['ip_addr']
                end
              end
            end

            srv.vm.provider 'virtualbox' do |vb, override|
              override.vm.box = machine['box']
              vb.memory = machine['ram']
              vb.cpus = machine['vcpu']
              vb.customize [
                "modifyvm", :id,
                "--nictype1", "virtio",
        	      "--natdnshostresolver1", "on",
              ]
            end

          when "aws"
            srv.vm.provider :aws do |aws, override|
              override.vm.box = machine['box']
              # aws.aws_dir = ENV['HOME'] + "/.aws/"
              # aws.session_token = "SESSION TOKEN"
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
                "Name" => machine['tags']['name'],
                "Team" => machine['tags']['team']
              }
              aws.ami = machine['ami']
              override.ssh.username = "admin"
              override.ssh.private_key_path = machine['private_key_path']
          end
        end

        config.vm.provision "ansible" do |ansible|
          ansible.compatibility_mode = "2.0"
          ansible.verbose = ""
          ansible.playbook = machine['playbook']
          ansible.limit = "tag_Name_" + machine['tags']['name']
          ansible.inventory_path = machine['inventory']
        end
      end
    end
  end
end
