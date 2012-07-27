# Cookbook Name:: woodenbits
# Recipe:: sys-packages

execute "update apt" do
  command 'apt-get -q -y update'
  action :nothing
end

execute "enable partners repo" do
  command 'apt-add-repository --yes "deb http://archive.canonical.com/ $(lsb_release -sc) partner"'
  # notifies :run, resources(:execute => "update apt")
  notifies :run, 'execute[update apt]', :immediately
  not_if %q(grep -e '^deb.\+partner' /etc/apt/sources.list)
end

execute "enable pgld repo" do
  command 'apt-add-repository --yes ppa:jre-phoenix/ppa'
  #notifies :run, resources(:execute => "update apt")
  notifies :run, 'execute[update apt]', :immediately
  creates '/etc/apt/sources.list.d/jre-phoenix-ppa-precise.list'
end

# maybe useful kernel options: i915.i915_enable_fbc=1 i915.lvds_downclock=1

package 'aptitude'

package 'build-essential'

# for compiling you own kernel
#package 'fakeroot'
#package 'kernel-package'
#package 'linux-source'

package 'ia32-libs'

#package 'libshadow-ruby1.8' # for chef user password support (ruby-shadow)
package 'ruby'
package 'rake'

package 'vim-gtk'
package 'screen'
package 'skype'

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
#package 'udftools'
package 'hfsprogs'
package 'deluge'

package 'logrotate'
package 'checkinstall'

#execute 'restart pgld' do
#  command 'pglcmd restart'
#  action :nothing
#end

#package 'pgld'
# brings popup, needs interactive console

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
package 'uswsusp'

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
end
