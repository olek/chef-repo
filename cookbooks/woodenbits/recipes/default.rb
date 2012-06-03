# Cookbook Name:: woodenbits
# Recipe:: default

#Chef::Log.info "fqdn = #{node[:fqdn]}, hostname = #{node[:hostname]}"

=begin

package "apt-transport-https" do
  options "--force-yes"
end

template "/etc/apt/sources.list" do
  source "sources.list.#{node[:platform_version]}.erb"
  mode 0644
  owner "root"
  group "root"
  notifies :run, resources(:execute => "update system"), :immediately
  not_if { File.exists?("/etc/apt/sources.list.no_chef") }
end

template "/etc/crontab" do
  source "crontab.erb"
  mode 0644
  owner "root"
  group "root"
end

directory "/root/build" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end
=end

directory "/root/tmp" do
  owner "root"
  group "root"
  mode "0700"
  action :create
end

directory "/root/tmp/vi" do
  owner "root"
  group "root"
  mode "0700"
  action :create
end


if node[:platform] == 'ubuntu' && node[:platform_version] == '12.04'
  template "/etc/polkit-1/localauthority/50-local.d/com.ubuntu.enable-hibernate.pkla" do
    source "com.ubuntu.enable-hibernate.pkla.erb"
    mode 0644
    owner "root"
    group "root"
  end
end

=begin
template "/etc/motd.tail" do
  source "motd-tail.erb"
  variables(
    :roles => node.run_list.roles,
    :services => node[:penthera][:services]
  )
  mode 0644
  owner "root"
  group "root"
end

template "/etc/bash.bashrc" do
  source "global-bashrc.erb"
  variables(
    :roles => node.run_list.roles,
    :services => node[:penthera][:services]
  )
  mode 0644
  owner "root"
  group "root"
end

template "/root/.profile" do
  source "profile.erb"
  mode 0644
  owner "root"
  group "root"
end

template "/root/.bashrc" do
  source "root-bashrc.erb"
  mode 0644
  owner "root"
  group "root"
end

template "/root/.vimrc" do
  source "vimrc.erb"
  mode 0644
  owner "root"
  group "root"
end

template "/root/.inputrc" do
  source "inputrc.erb"
  mode 0644
  owner "root"
  group "root"
end

template "/root/.screenrc" do
  source "screenrc.erb"
  variables(
    :is_root => true,
    :logs_home => '/var/log'
  )
  mode 0640
  owner "root"
  group "root"
  not_if { node[:penthera][:services].include?('workstation') }
end
=end

package "build-essential"

package "vim-gtk"
package "screen"

case node[:platform]
when "debian", "ubuntu"
  package "git-core"
else
  package "git"
end

package "httperf"

package "sysstat"
package "ethstatus"

package "mlocate"
package "telnet"
package "dnsutils"
package "curl"

package "logrotate"
package "checkinstall"
