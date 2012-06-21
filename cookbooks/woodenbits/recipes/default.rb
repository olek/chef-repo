# Cookbook Name:: woodenbits
# Recipe:: default

#Chef::Log.info "fqdn = #{node[:fqdn]}, hostname = #{node[:hostname]}"

if node[:platform] == 'ubuntu' && node[:platform_version] == '12.04'
  template "/etc/polkit-1/localauthority/50-local.d/com.ubuntu.enable-hibernate.pkla" do
    source "com.ubuntu.enable-hibernate.pkla.erb"
    mode 0644
    owner "root"
    group "root"
  end
end

%w(root olek).each do |user|
  home_dir = user == 'root' ? "/#{user}" : "/home/#{user}"

  %w(tmp tmp/vi build .bashrc.d .janus).each do |dir|
    directory "#{home_dir}/#{dir}" do
      owner user
      group user
      mode "0750"
      action :create
    end
  end

  directory "#{home_dir}/.ssh" do
    owner user
    group user
    mode "0700"
    action :create
  end

  template "#{home_dir}/.ssh/config" do
    source "ssh-config.erb"
    mode 0600
    owner user
    group user
  end

  template "#{home_dir}/.gitconfig" do
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

  template "#{home_dir}/.screenrc" do
    source "screenrc.erb"
    variables(
      :is_root => user == 'root'
    )
    mode 0640
    owner user
    group user
  end

  %w(inputrc profile bashrc vimrc.after gvimrc.after gemrc irbrc).each do |name|
    template "#{home_dir}/.#{name}" do
      source "#{name}.erb"
      mode 0640
      owner user
      group user
    end
  end

  %w(05-settings 10-path 20-functions 30-aliases 40-prompt 50-other).each do |name|
    template "#{home_dir}/.bashrc.d/#{name}" do
      source "bashrc.d/#{name}.erb"
      mode 0740
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
      creates "#{home_dir}/.janus/#{repo}"
    end
  end
end

package "build-essential"
package "ruby"
package "rake"

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
package "wine-gecko1.4"

#package "synergy"

bash "install synergy" do
  version = '1.3.7'
  cwd "/tmp"
  code <<-EOH
    wget http://synergy.googlecode.com/files/synergy-#{version}-Linux-i686.deb
    sudo dpkg --install synergy-#{version}-Linux-i686.deb
    sudo apt-mark hold synergy
    rm synergy-#{version}-Linux-i686.deb
  EOH
  creates '/usr/bin/synergyc'
end
