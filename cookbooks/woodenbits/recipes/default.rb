# Cookbook Name:: woodenbits
# Recipe:: default

#Chef::Log.info "fqdn = #{node[:fqdn]}, hostname = #{node[:hostname]}"

if node[:platform] == 'ubuntu' && node[:platform_version] == '12.04'
  template '/etc/polkit-1/localauthority/50-local.d/com.ubuntu.enable-hibernate.pkla' do
    source 'com.ubuntu.enable-hibernate.pkla.erb'
    mode 0644
    owner 'root'
    group 'root'
  end
end

directory '/etc/pgl' do
  mode '0755'
  action :create
end

%w(pglcmd.conf blocklists.list).each do |fname|
  template "/etc/pgl/#{fname}" do
    source "system/etc/pgl-#{fname}.erb"
    mode 0644
    owner 'root'
    group 'root'
  end
end

package 'aptitude'
package 'build-essential'
package 'ruby'
package 'rake'

package 'vim-gtk'
package 'screen'

case node[:platform]
when 'debian', 'ubuntu'
  package 'git-core'
else
  package 'git'
end

package 'httperf'

package 'sysstat'
package 'ethstatus'

package 'mlocate'
package 'telnet'
package 'dnsutils'
package 'curl'

package 'logrotate'
package 'checkinstall'

package 'dosbox'
package 'wine'
package 'wine-gecko1.4'

#execute 'restart pgld' do
#  command 'pglcmd restart'
#  action :nothing
#end

#package 'pgld'
# brings popup, needs interactive console
#package 'pglcmd'
#package 'pgl-gui'

package 'powertop'
package 'powertop-1.13'
package 'fatrace'
package 'smartmontools'
package 'iotop'
package 'dstat'

execute "turn off chef-client verbose logging" do
  command "echo 'verbose_logging false' >> /etc/chef/client.rb"
  not_if "grep 'verbose_logging false' /etc/chef/client.rb"
end

=begin
package 'laptop-mode-tools'
%w(
ac97-powersave auto-hibernate battery-level-polling bluetooth configuration-file-control
cpufreq dpms-standby eee-superhe ethernet exec-commands hal-polling intel-hda-powersave
intel-sata-powermgmt lcd-brightness nmi-watchdog runtime-pm sched-mc-power-savings
sched-smt-power-savings start-stop-programs terminal-blanking usb-autosuspend video-out
wireless-ipw-power wireless-iwl-power wireless-power
).each do |name|
  template "/etc/laptop-mode/conf.d/#{name}.conf" do
    source "system/etc/laptop-mode.conf.d/#{name}.conf"
    mode 0644
  end
end
=end

package 'synergy' do
  action :remove
  only_if "synergyc --version | grep -v '1.3.7'"
end

bash 'install synergy' do
  version = '1.3.7' # 1.3.8.generates core dumps
  cwd '/tmp'
  code <<-EOH
    wget http://synergy.googlecode.com/files/synergy-#{version}-Linux-i686.deb
    sudo dpkg --install synergy-#{version}-Linux-i686.deb
    sudo apt-mark hold synergy
    rm synergy-#{version}-Linux-i686.deb
  EOH
  creates '/usr/bin/synergyc'
end


directory '/root/install' do
  mode '0755'
  action :create
end

#truecrypt_archive = 'truecrypt_7.1a_console_i386.tar.gz'
truecrypt_archive = 'truecrypt_7.1a_i386.tar.gz'
cookbook_file "/root/install/#{truecrypt_archive}" do
  source truecrypt_archive
  mode 0640
end

bash 'install truecrypt' do
  cwd '/'
  code <<-EOH
    tar xfz /root/install/#{truecrypt_archive}
  EOH
  creates '/usr/bin/truecrypt'
end

users = ['olek']

template '/etc/sudoers.d/truecrypt' do
  source 'system/etc/sudoers-truecrypt.erb'
  variables(
    :users => users
  )
  mode 0440
end

(users + ['root']).each do |user|
  home_dir = user == 'root' ? "/#{user}" : "/home/#{user}"

  %w(tmp tmp/vi build .bashrc.d .janus).each do |dir|
    directory "#{home_dir}/#{dir}" do
      owner user
      group user
      mode '0750'
      action :create
    end
  end

  directory "#{home_dir}/.ssh" do
    owner user
    group user
    mode '0700'
    action :create
  end

  template "#{home_dir}/.ssh/config" do
    source 'ssh-config.erb'
    mode '0600'
    owner user
    group user
  end

  template "#{home_dir}/.gitconfig" do
    source 'gitconfig.erb'
    variables(
      :username => 'olek',
      :name => 'Olek Poplavsky',
      :email => 'olek@woodenbits.com'
    )
    mode '0640'
    owner user
    group user
  end

  template "#{home_dir}/.screenrc" do
    source 'screenrc.erb'
    variables(
      :is_root => user == 'root'
    )
    mode '0640'
    owner user
    group user
  end

  %w(inputrc bashrc vimrc.before vimrc.after gvimrc.after gemrc irbrc).each do |name|
    template "#{home_dir}/.#{name}" do
      source "#{name}.erb"
      mode '0640'
      owner user
      group user
    end
  end

  %w(05-settings 10-path 20-functions 30-aliases 40-prompt 50-other).each do |name|
    template "#{home_dir}/.bashrc.d/#{name}" do
      source "bashrc.d/#{name}.erb"
      mode '0740'
      owner user
      group user
    end
  end

  # Execute the Janus bootstrap installation from github.
  execute "install janus for #{user}" do
    cmd = "curl -Lo- http://bit.ly/janus-bootstrap | bash"
    command %Q(sudo -H -u #{user} /bin/bash -c "#{cmd}")
    creates "#{home_dir}/.vim/bootstrap.sh"
  end

  %w(jgdavey/tslime.vim olek/vim-turbux).each do |repo|
    execute "clone #{repo} for #{user}" do
      cmd = "cd ~/.janus && git clone http://github.com/#{repo}.git"
      command %Q(sudo -H -u #{user} /bin/bash -c "#{cmd}")
      creates "#{home_dir}/.janus/#{repo.split('/').last}"
    end
  end
end
