# Cookbook Name:: woodenbits
# Recipe:: rvm

rvm_rubies = %w(1.9.3-p194 ree-1.8.7-2011.03)
user = 'olek'
user_home = "/home/#{user}"

# officially, we need all of those
#
# build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev
# libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf
# libc6-dev ncurses-dev automake libtool bison subversion

%w(readline ssl xml2 xslt1 yaml).each do |name|
  package "lib#{name}-dev"
end

package 'zlib1g-dev'

execute "install RVM" do
  command %Q(sudo -H -u #{user} /bin/bash -c "curl -L get.rvm.io | bash -s stable")
  not_if { File.exists?("#{user_home}/.rvm") }
end

rvm_rubies.each do |rvm_ruby|
  execute "install #{rvm_ruby} in RVM for user #{user}" do
    command %Q(sudo -H -u #{user} /bin/bash -l -c "rvm install #{rvm_ruby}")
    not_if { system %Q(sudo -H -u #{user} /bin/bash -l -c "rvm list | grep --quiet #{rvm_ruby}") }
  end
end

template "#{user_home}/.bash_login" do
  source "bash_login.erb"
  mode '0640'
  owner user
  group 'users'
end

#execute"make #{rvm_ruby} the default ruby for user #{user}" do
#  command %Q(sudo -H -u #{user} /bin/bash -l -c "rvm --default #{rvm_ruby}")
#  not_if { system %Q(sudo -H -u #{user} /bin/bash -l -c "env | grep --quiet '^MY_RUBY_HOME=#{user_home}/.rvm/rubies/#{rvm_ruby}'") }
#end
