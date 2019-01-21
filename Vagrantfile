# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"

$vm_cpus = 1
$vm_mem = 512
$ip_addr = "192.168.100.2"
ip_addr = $ip_addr
playbook = "./plays/site.yml"
inventory = "inventory"
host_name = "dockerhostvm"
box_name = "debian/contrib-stretch64"
plugins_dependencies = %w(
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

  File.open("#{inventory}", 'w') do |f|
      f.write "[#{host_name}]\n"
      f.write "#{ip_addr}\n"
  end

  config.vm.define "#{host_name}" do |node|
    node.vm.box = "#{box_name}"
    node.vm.hostname = "#{host_name}"
    node.vm.network "private_network", ip: $ip_addr
    node.vm.provider :virtualbox do |vb, override|
      vb.customize [
        "modifyvm", :id,
        "--memory", $vm_mem,
        "--cpus", $vm_cpus,
        "--nictype1", "virtio",
	      "--natdnshostresolver1", "on",
      ]
    end

    config.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.verbose = ""
      ansible.playbook = "#{playbook}"
      ansible.limit = "#{host_name}"
      ansible.inventory_path = "#{inventory}"
    end
  end

end
