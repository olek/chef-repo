# Cookbook Name:: woodenbits
# Recipe:: catnap
#
# System-level layer of the catnap userspace low-power suspend suite: the root
# engine and CLI, the systemd service that runs it under systemd-inhibit, the
# passwordless sudoers rule, and log rotation. This is the "basic" catnap: the
# manual `catnap` command works once this recipe has run.
#
# Add this recipe to a node's run_list (or a role) for basic catnap. For the
# automatic idle trigger, use woodenbits::catnap-idle instead, which includes
# this recipe.

%w(catnap catnap-engine).each do |script|
  template "/usr/local/bin/#{script}" do
    source "system/usr/local/bin/#{script}.erb"
    mode '0755'
  end
end

file '/etc/polkit-1/rules.d/50-catnap.rules' do
  action :delete
end

directory '/var/log/catnap' do
  owner 'root'
  group 'root'
  mode '0755'
end

file '/var/log/catnap/catnap.log' do
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

file '/etc/logrotate.d/catnap' do
  content <<~EOF
    /var/log/catnap/catnap.log {
      weekly
      rotate 4
      compress
      missingok
      notifempty
      copytruncate
    }
  EOF
  owner 'root'
  group 'root'
  mode '0644'
end

template '/etc/sudoers.d/catnap' do
  source 'system/etc/sudoers.d/catnap.erb'
  owner 'root'
  group 'root'
  mode '0440'
end

execute 'reload systemd for catnap' do
  command 'systemctl daemon-reload'
  action :nothing
end

file '/usr/local/sbin/catnap-watcher' do
  action :delete
end

file '/etc/systemd/system/catnap@.service' do
  action :delete
  notifies :run, 'execute[reload systemd for catnap]', :immediately
end

template '/etc/systemd/system/catnap.service' do
  source 'system/etc/systemd/system/catnap.service.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[reload systemd for catnap]', :immediately
end

include_recipe 'woodenbits::catnap-idle'
include_recipe 'woodenbits::catnap-powerbtn'
