# Cookbook Name:: woodenbits
# Recipe:: rvm

rvm_ruby = '1.9.3-p194'
user = 'olek'
user_home = "/home/#{user}"

# officially, we need all of those
#
# build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev
# libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf
# libc6-dev ncurses-dev automake libtool bison subversion

package 'libreadline-dev' # needed for irb history to work
package 'zlib1g-dev' # or 'gem install bundler' will fail
package 'libssl-dev' # or some rake tasks will fail

execute "install RVM" do
  command %Q(sudo -H -u #{user} /bin/bash -c "curl -L get.rvm.io | bash -s stable")
  not_if { File.exists?("#{user_home}/.rvm") }
end

execute "install #{rvm_ruby} in RVM for user #{user}" do
  command %Q(sudo -H -u #{user} /bin/bash -l -c "rvm install #{rvm_ruby}")
  not_if { system %Q(sudo -H -u #{user} /bin/bash -l -c "rvm list | grep --quiet #{rvm_ruby}") }
end

execute"make #{rvm_ruby} the default ruby for user #{user}" do
  command %Q(sudo -H -u #{user} /bin/bash -l -c "rvm --default #{rvm_ruby}")
  not_if { system %Q(sudo -H -u #{user} /bin/bash -l -c "env | grep --quiet '^MY_RUBY_HOME=#{user_home}/.rvm/rubies/#{rvm_ruby}'") }
end
