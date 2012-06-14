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
  owner user
  group user
  notifies :run, resources(:execute => "update system"), :immediately
  not_if { File.exists?("/etc/apt/sources.list.no_chef") }
end

template "/etc/crontab" do
  source "crontab.erb"
  mode 0644
  owner user
  group user
end
=end

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

template "#{home}/.profile" do
  source "profile.erb"
  mode 0644
  owner user
  group user
end

template "#{home}/.bashrc" do
  source "root-bashrc.erb"
  mode 0644
  owner user
  group user
end
=end

%w(root olek).each do |user|
  home = user == 'root' ? "/#{user}" : "/home/#{user}"

  directory "#{home}/tmp" do
    owner user
    group user
    mode "0700"
    action :create
  end

  directory "#{home}/tmp/vi" do
    owner user
    group user
    mode "0700"
    action :create
  end

  directory "#{home}/build" do
    owner user
    group user
    mode "0750"
    action :create
  end

  directory "#{home}/.bashrc.d" do
    owner user
    group user
    mode "0750"
    action :create
  end

  template "#{home}/.gitconfig" do
    source "gitconfig.erb"
    variables(
      :username => 'olek',
      :name => 'Olek Poplavsky',
      :email => 'olek@woodenbits.com'
    )
    mode 0640
    owner user
    group user
  end

  template "#{home}/.screenrc" do
    source "screenrc.erb"
    variables(
      :is_root => user == 'root'
    )
    mode 0640
    owner user
    group user
  end

  template "#{home}/.vimrc" do
    source "vimrc.erb"
    mode 0640
    owner user
    group user
  end

  template "#{home}/.inputrc" do
    source "inputrc.erb"
    mode 0640
    owner user
    group user
  end

  template "#{home}/.bashrc" do
    source "bashrc.erb"
    mode 0640
    owner user
    group user
  end

  template "#{home}/.bashrc.d/05-settings" do
    source "bashrc.d/05-settings.erb"
    mode 0740
    owner user
    group user
  end

  template "#{home}/.bashrc.d/10-path" do
    source "bashrc.d/10-path.erb"
    mode 0740
    owner user
    group user
  end

  template "#{home}/.bashrc.d/20-functions" do
    source "bashrc.d/20-functions.erb"
    mode 0740
    owner user
    group user
  end

  template "#{home}/.bashrc.d/30-aliases" do
    source "bashrc.d/30-aliases.erb"
    mode 0740
    owner user
    group user
  end

  template "#{home}/.bashrc.d/40-prompt" do
    source "bashrc.d/40-prompt.erb"
    mode 0740
    owner user
    group user
  end

  template "#{home}/.bashrc.d/50-other" do
    source "bashrc.d/50-other.erb"
    mode 0740
    owner user
    group user
  end
end

package "build-essential"
package "ruby"

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

package "dosbox"
package "wine"
package "wine-gecko"
