# Cookbook Name:: woodenbits
# Recipe:: dev-modcloth

#package 'libqtwebkit-dev' # capybara-webkit gem dependency
#package 'libcurl4-openssl-dev' # curb gem dependency

#package 'redis-server'
#package 'mysql-server'
#package 'libmysqlclient-dev'
#package 'libmagickwand-dev'

# VPN
package 'openconnect'
package 'network-manager-openconnect'

execute "pre-agree to oracle java7 license" do
  command "echo 'oracle-java7-installer shared/accepted-oracle-license-v1-1 select true' | debconf-set-selections"
  not_if { File.exists?("/usr/lib/jvm/java-7-oracle/jre/bin/java") }
end

execute "pre-agree to oracle java8 license" do
  command "echo 'oracle-java8-installer shared/accepted-oracle-license-v1-1 select true' | debconf-set-selections"
  not_if { File.exists?("/usr/lib/jvm/java-8-oracle/jre/bin/java") }
end

package 'oracle-java7-installer'
package 'oracle-java8-installer'
