# Cookbook Name:: woodenbits
# Recipe:: sys-packages

# maybe useful kernel options: i915.i915_enable_fbc=1 i915.lvds_downclock=1

package 'ubuntu-restricted-extras'

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

# user tools
package 'vim-gtk'
package 'screen'
package 'skype'
package 'xournal'
package 'gimp'

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
package 'sshfs'
package 'cifs-utils'
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
package 'ethtool'
package 'dconf-tools'

package 'dosbox'
package 'wine'
package 'wine-gecko1.4'

package 'google-chrome-stable'
package 'chromium-browser'
package 'compizconfig-settings-manager'

%w(sysmonitor keylock ubuntuone).each do |name|
  package "indicator-#{name}"
end
package 'touchpad-indicator'

package 'unity-lens-utilities'
package 'unity-scope-calculator'
package 'unity-scope-cities'
package 'unity-scope-rottentomatoes'

package 'python-gpgme' # for dropbox

package 'radiotray'

package 'ubuntu-restricted-extras'

package 'vlc'
package 'smplayer'
package 'w64codecs'
package 'libdvdcss2'

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
  #arch = 'i686'
  arch = 'x86_64'
  cwd '/tmp'
  code <<-EOH
    cd /root/install
    wget http://synergy.googlecode.com/files/synergy-#{version}-Linux-#{arch}.deb
    sudo dpkg --install synergy-#{version}-Linux-#{arch}.deb
    sudo apt-mark hold synergy
    rm synergy-#{version}-Linux-#{arch}.deb
  EOH
  creates '/usr/bin/synergyc'
end
