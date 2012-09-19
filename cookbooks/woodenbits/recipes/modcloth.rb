# Cookbook Name:: woodenbits
# Recipe:: modcloth

package 'libqtwebkit-dev' # capybara-webkit gem dependency

#package 'libyajl-dev' # maybe not needed, maybe needed for ruby-yajl gem to work
package 'libcurl4-openssl-dev' # curb gem dependency

package 'redis-server'
package 'mysql-server'
package 'libmysqlclient-dev'
package 'libmagickwand-dev'
package 'freetds-dev'


#execute "pre-agree to sun java license" do
#  command "echo 'sun-java6-jdk shared/accepted-sun-dlj-v1-1 boolean true' | debconf-set-selections"
#  not_if { File.exists?("/usr/lib/jvm/java-6-sun/jre/bin/java") }
#end

#package "sun-java6-jdk"
#package "ant"
#package "ant-optional"

package 'oracle-java7-installer'
