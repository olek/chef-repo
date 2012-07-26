# Cookbook Name:: woodenbits
# Recipe:: rbenv

rbenv_ruby = '1.9.3-p194'
user = 'olek'
user_home = "/home/#{user}"

rbenv_bin = "#{user_home}/.rbenv/bin/rbenv"

package 'libreadline-dev' # needed for irb history to work
package 'zlib1g-dev' # or 'gem install bundler' will fail
package 'libssl-dev' # or some rake tasks will fail

unless rbenv_ruby.empty?
  execute "install rbenv" do
    command %Q(sudo -H -u #{user} /bin/bash -c "git clone git://github.com/sstephenson/rbenv.git ~/.rbenv && git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/install")
    not_if { File.exists?("#{user_home}/.rbenv") }
  end

  unless rbenv_ruby == 'system'
    execute "install #{rbenv_ruby} in rbenv for user #{user}" do
      command %Q(sudo -H -u #{user} /bin/bash -c "cd ~/.rbenv && git pull-ff && cd plugins/install && git pull-ff && cd && #{rbenv_bin} install #{rbenv_ruby}")
      # without silly 'cd' command, it generates warning/error: "rbenv: line 20: cd: /root: Permission denied"
      not_if { system "cd #{user_home} && sudo -H -u #{user} #{rbenv_bin} versions | grep --quiet #{rbenv_ruby}" }
    end
  end

  execute"make #{rbenv_ruby} the default ruby for user #{user}" do
    command "sudo -H -u #{user} #{rbenv_bin} global #{rbenv_ruby}"
    not_if { system "cd #{user_home} && sudo -H -u #{user} #{rbenv_bin} global | grep --quiet #{rbenv_ruby}" }
  end
end
