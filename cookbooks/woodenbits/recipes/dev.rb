# Cookbook Name:: woodenbits
# Recipe:: dev

include_recipe 'woodenbits::rbenv'
#include_recipe 'woodenbits::dev-modcloth'

# ========== dev / user tools
package 'exuberant-ctags'
package 'global'

package 'sqlite3'
package 'libsqlite3-dev'
package 'sqliteman'

# ========== dev tools

#package 'libshadow-ruby1.8' # for chef user password support (ruby-shadow)

package 'httperf'

#package 'virtualbox'
#package 'vagrant'

#package 'postgresql'
#package 'libpq-dev'
#package 'pgadmin3'

package 'nodejs'
package 'jq' # json pretty print

#execute "pre-agree to oracle java7 license" do
#  command "echo 'oracle-java7-installer shared/accepted-oracle-license-v1-1 select true' | debconf-set-selections"
#  not_if { File.exists?("/usr/lib/jvm/java-7-oracle/jre/bin/java") }
#end
#package 'oracle-java7-installer'

execute "pre-agree to oracle java8 license" do
  command "echo 'oracle-java8-installer shared/accepted-oracle-license-v1-1 select true' | debconf-set-selections"
  not_if { File.exists?("/usr/lib/jvm/java-8-oracle/jre/bin/java") }
end

package 'oracle-java8-installer'
