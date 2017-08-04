# Cookbook Name:: woodenbits
# Recipe:: user-config

users =
  if node[:sessions]
    node[:sessions][:by_user].keys - ['root']
  else
    if node[:etc][:passwd].key?('opoplavsky')
      ['opoplavsky']
    else
      []
    end
  end

git_configs = {
  "alias.br" => "branch",
  "alias.bra" => "branch -a",
  "alias.ci" => "commit",
  "alias.co" => "checkout",
  "alias.cp" => "cherry-pick",
  "alias.dc" => "diff --cached",
  "alias.di" => "diff",
  "alias.g" => "log --pretty=format:\"%h %an - %s\" --graph",
  "alias.gg" => "log --pretty=format:\"%H %an - %s\" --graph",
  "alias.lc" => "log ORIG_HEAD.. --stat --no-merges",
  "alias.ll" => "log --pretty=format:\"%Cred%h %Cblue%an %Cgreen%s / %Cblue%ar%Creset\" --abbrev-commit -n15",
  "alias.st" => "status",
  "alias.s" => "status --short",
  "alias.w" => "whatchanged",
  "alias.pull-ff" => "pull --ff-only",
  "alias.edit-unmerged" => "!f() { git ls-files --unmerged | cut -f2 | sort -u ; }; tvim `f`",
  "alias.add-unmerged" => "!f() { git ls-files --unmerged | cut -f2 | sort -u ; }; git add `f`",
#  "alias.down" => "!sh -c \"CURRENT=$(git symbolic-ref HEAD | sed -e s@.*/@@) && (git pull --ff-only || (git fetch origin && git rebase --preserve-merges origin/$CURRENT))\"",
#  "alias.publish" => "!f() { if [ $# -ne 1 ]; then echo \"usage: git publish <local-branch-name>\" >&2; exit 1; fi; git push --set-upstream origin $1:$1; }; f",
#  "alias.unpublish" => "!f() { if [ $# -ne 1 ]; then echo \"usage: git unpublish <remote-branch-name>\" >&2; exit 1; fi; git push origin :$1; }; f",

  "color.branch" => "auto",
  "color.diff" => "auto",
  "color.interactive" => "auto",
  "color.status" => "auto",
  "color.ui" => "true",
  "color.grep" => "auto",

  "core.excludesfile" => "~/.gitignore",

  "branch.autosetuprebase" => "never",
  "branch.autosetupmerge" => "true",

  "apply.whitespace" => "fix",
  "grep.lineNumber " => "true",
  "pull.rebase" => "true",
  "push.default" => "current",

  "diff.tool" => "diffmerge",
  "difftool.diffmerge.cmd" => "diffmerge \"$LOCAL\" \"$REMOTE\"",
  "merge.tool" => "diffmerge",
  "mergetool.diffmerge.cmd" => "diffmerge --merge --result=\"$MERGED\" \"$LOCAL\" \"$(if test -f \"$BASE\"; then echo \"$BASE\"; else echo \"$LOCAL\"; fi)\" \"$REMOTE\"",
  "mergetool.diffmerge.trustExitCode" => "true",
}


template '/etc/sudoers.d/truecrypt' do
  source 'system/etc/sudoers-truecrypt.erb'
  variables(
    :users => users
  )
  mode 0440
end

template "/root/chef-notes.txt" do
  source 'chef-notes.erb'
  mode '0600'
  owner 'root'
  group 'root'
end

directory '/root/install' do
  mode '0755'
  action :create
end


(users + ['root']).each do |user|
  home_dir = user == 'root' ? '/root' : "/home/#{user}"
  user_group = `id --group --name #{user}`.chomp

  %w(tmp tmp/vi .vim .vim/bundle build .bashrc.d .mplayer).each do |dir|
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
    action :create_if_missing
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

  template "#{home_dir}/.tmux.conf" do
    source 'tmux.conf.erb'
    mode '0640'
    owner user
    group user_group
  end

  %w(inputrc bashrc vimrc gvimrc gemrc irbrc).each do |name|
    template "#{home_dir}/.#{name}" do
      source "#{name}.erb"
      mode '0640'
      owner user
      group user_group
    end
  end

  %w(05-settings 10-functions 20-path 30-aliases 40-prompt 50-other).each do |name|
    template "#{home_dir}/.bashrc.d/#{name}" do
      source "bashrc.d/#{name}.erb"
      mode '0740'
      owner user
      group user_group
    end
  end

  # killing old files
  #%w(10-path 20-functions).each do |name|
  #  file "#{home_dir}/.bashrc.d/#{name}" do
  #    action :delete
  #  end
  #end

  # Execute the Janus bootstrap installation from github.
  #execute "install janus for #{user}" do
  #  cmd = "curl -Lo- http://bit.ly/janus-bootstrap | bash"
  #  command %Q(sudo -H -u #{user} /bin/bash -c "#{cmd}")
  #  creates "#{home_dir}/.vim/bootstrap.sh"
  #end

  #%w(jgdavey/tslime.vim olek/vim-turbux).each do |repo|
  #  execute "clone #{repo} for #{user}" do
  #    cmd = "cd ~/.janus && git clone http://github.com/#{repo}.git"
  #    command %Q(sudo -H -u #{user} /bin/bash -c "#{cmd}")
  #    creates "#{home_dir}/.janus/#{repo.split('/').last}"
  #  end
  #end

  # Install Vundle from github.
  execute "install Vundle for #{user}" do
    cmd = "git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim"
    command %Q(sudo -H -u #{user} /bin/bash -c "#{cmd}")
    creates "#{home_dir}/.vim/bundle/Vundle.vim"
  end
end

users.each do |user|
  home_dir = "/home/#{user}"
  user_group = `id --group --name #{user}`.chomp

=begin
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
=end

  directory "#{home_dir}/.tmuxstart" do
    owner user
    group user_group
    mode '0700'
    action :create
  end

  %w(general monologue ormivore).each do |name|
    template "#{home_dir}/.tmuxstart/#{name}" do
      source "tmuxstart/#{name}.erb"
      mode '0600'
      owner user
      group user_group
    end
  end

  template "#{home_dir}/bin/truecrypt-init.sh" do
    source 'truecrypt-init.erb'
    mode '0500'
    owner user
    group user_group
  end

  template "#{home_dir}/bin/timed" do
    source 'timed.erb'
    mode '0500'
    owner user
    group user_group
  end

  template "#{home_dir}/.mplayer/config" do
    source 'mplayer-config.erb'
    mode '0640'
    owner user
    group user_group
  end

  directory "#{home_dir}/.gconf/apps/rapid-photo-downloader" do
    owner user
    group user_group
    recursive true
    mode '0750'
    action :create
  end

  cookbook_file "#{home_dir}/.gconf/apps/rapid-photo-downloader/%gconf.xml" do
    source "rapid-downloader-conf.xml"
    mode 0600
    action :create_if_missing
  end

  ## install ntfy package - not desirable anymore since its shell integration is broken for me
  #execute "install ntfy for #{user}" do
  #  cmd = "pip install ntfy"
  #  command %Q(sudo -H -u #{user} /bin/bash -c "#{cmd}")
  #  creates "#{home_dir}/.local/bin/ntfy"
  #end
end

# can not change gnome settings for non-current user

users.each do |user|
  sudo = "sudo -H -u #{user} /bin/bash -c"
  execute "disable auto-mount pop-up for user #{user}" do
    command %Q(#{sudo} "gsettings set org.gnome.desktop.media-handling automount-open false")
    not_if %Q(#{sudo} "gsettings get org.gnome.desktop.media-handling automount-open | grep -q false")
  end

  local_git_configs = git_configs

  if user == 'olek'
    local_git_configs = git_configs.merge(
      'user.name' => 'Olek Poplavsky',
      'user.email' => 'olek@woodenbits.com'
    )
  end

  local_git_configs.each do |k, v|
    execute "set global git config #{k}" do
      command "git config --global #{k} \'#{v}\'"
      user user
      not_if "git config --global #{k} | grep -q \'#{v}\'"
    end
  end
end
