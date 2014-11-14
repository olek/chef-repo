# Cookbook Name:: woodenbits
# Recipe:: dev

include_recipe 'woodenbits::rbenv'
include_recipe 'woodenbits::dev-modcloth'

# ========== dev / user tools

package 'screen'
package 'tmux'
package 'exuberant-ctags'

package 'sqlite3'
package 'libsqlite3-dev'

# ========== dev tools

case node[:platform]
when 'debian', 'ubuntu'
  package 'git-core'
else
  package 'git'
end

#package 'libshadow-ruby1.8' # for chef user password support (ruby-shadow)
package 'ruby'
package 'rake'

package 'httperf'

package 'virtualbox'
package 'vagrant'

package 'postgresql'
#package 'postgresql-server-dev-9.3'
package 'libpq-dev'
package 'pgadmin3'

package 'nodejs'
package 'jq' # json pretty print
