# Cookbook Name:: woodenbits
# Recipe:: user-config

users = ['olek']

template '/etc/sudoers.d/truecrypt' do
  source 'system/etc/sudoers-truecrypt.erb'
  variables(
    :users => users
  )
  mode 0440
end

(users + ['root']).each do |user|
  home_dir = user == 'root' ? '/root' : "/home/#{user}"
  user_group = user == 'root' ? 'root' : 'users'

  %w(tmp tmp/vi build .bashrc.d .janus).each do |dir|
    directory "#{home_dir}/#{dir}" do
      owner user
      group user_group
      mode '0750'
      action :create
    end
  end

  directory "#{home_dir}/bin" do
    owner user
    group user_group
    mode '0750'
    action :create
  end

  directory "#{home_dir}/.ssh" do
    owner user
    group user_group
    mode '0700'
    action :create
  end

  template "#{home_dir}/.ssh/config" do
    source 'ssh-config.erb'
    mode '0600'
    owner user
    group user_group
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
    group user_group
  end

  template "#{home_dir}/.screenrc" do
    source 'screenrc.erb'
    variables(
      :is_root => user == 'root'
    )
    mode '0640'
    owner user
    group user_group
  end

  %w(inputrc bashrc vimrc.before vimrc.after gvimrc.after gemrc irbrc).each do |name|
    template "#{home_dir}/.#{name}" do
      source "#{name}.erb"
      mode '0640'
      owner user
      group user_group
    end
  end

  %w(05-settings 10-path 20-functions 30-aliases 40-prompt 50-other).each do |name|
    template "#{home_dir}/.bashrc.d/#{name}" do
      source "bashrc.d/#{name}.erb"
      mode '0740'
      owner user
      group user_group
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

# can not change gnome settings for non-current user
current_user = node[:current_user]

if current_user && current_user != 'root'
  execute "disable auto-mount pop-up for user #{current_user}" do
    sudo = "sudo -H -u #{current_user} /bin/bash -c"
    command %Q(#{sudo} "gsettings set org.gnome.desktop.media-handling automount-open false")
    only_if %Q(#{sudo} "gsettings get org.gnome.desktop.media-handling automount-open | grep true")
  end
else
  Chef::Log.info "No gnome settings changes performed for user #{current_user}"
end
