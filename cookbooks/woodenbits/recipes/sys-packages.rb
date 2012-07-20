# Cookbook Name:: woodenbits
# Recipe:: sys-packages

package 'aptitude'
package 'build-essential'
#package 'libshadow-ruby1.8' # for chef user password support (ruby-shadow)
package 'ruby'
package 'rake'

package 'vim-gtk'
package 'screen'

case node[:platform]
when 'debian', 'ubuntu'
  package 'git-core'
else
  package 'git'
end

package 'httperf'

package 'sysstat'
package 'ethstatus'

package 'mlocate'
package 'telnet'
package 'dnsutils'
package 'curl'
package 'gparted'
package 'udftools'

package 'logrotate'
package 'checkinstall'

#execute 'restart pgld' do
#  command 'pglcmd restart'
#  action :nothing
#end

#package 'pgld'
# brings popup, needs interactive console
#package 'pglcmd'
#package 'pgl-gui'

package 'powertop'
package 'powertop-1.13'
package 'fatrace'
package 'smartmontools'
package 'iotop'
package 'dstat'
package 'hwinfo'
package 'lm-sensors'
package 'xsensors'
#package 'cpufrequtils'

package 'dosbox'
package 'wine'
package 'wine-gecko1.4'

package 'chromium-browser'

package 'synergy' do
  action :remove
  only_if "synergyc --version | grep '1.3.8'"
end

directory '/root/install' do
  mode '0755'
  action :create
end

bash 'install synergy' do
  version = '1.3.7' # 1.3.8.generates core dumps
  cwd '/tmp'
  code <<-EOH
    cd /root/install
    wget http://synergy.googlecode.com/files/synergy-#{version}-Linux-i686.deb
    sudo dpkg --install synergy-#{version}-Linux-i686.deb
    sudo apt-mark hold synergy
    rm synergy-#{version}-Linux-i686.deb
  EOH
  creates '/usr/bin/synergyc'
  not_if "synergyc --version"
end

#truecrypt_archive = 'truecrypt_7.1a_console_i386.tar.gz'
truecrypt_archive = 'truecrypt_7.1a_i386.tar.gz'
cookbook_file "/root/install/#{truecrypt_archive}" do
  source truecrypt_archive
  mode 0640
end

bash 'install truecrypt' do
  cwd '/'
  code <<-EOH
    tar xfz /root/install/#{truecrypt_archive}
  EOH
  creates '/usr/bin/truecrypt'
end
