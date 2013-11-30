# Cookbook Name:: woodenbits
# Recipe:: sys-packages

# maybe useful kernel options: i915.i915_enable_fbc=1 i915.lvds_downclock=1

# ========== essentials

package 'aptitude'
package 'ubuntu-restricted-extras'
package 'build-essential'

# compile your own kernel
#package 'fakeroot'
#package 'kernel-package'
#package 'linux-source'


# ========== user tools

package 'vim-gtk'
package 'screen'
package 'tmux'
package 'skype'
package 'xournal'
package 'gimp'
package 'calibre'
package 'exuberant-ctags'

package 'deluge'
package 'dvdrip'
package 'rar'

package 'sqlite3'
package 'libsqlite3-dev'

package 'wmctrl' # for window resize script resize.rb

package 'google-chrome-stable'
package 'chromium-browser'
package 'compizconfig-settings-manager'

%w(sysmonitor keylock ubuntuone).each do |name|
  package "indicator-#{name}"
end
package 'touchpad-indicator'

#package 'unity-lens-utilities'
package 'unity-scope-calculator'
#package 'unity-scope-cities'
#package 'unity-scope-rottentomatoes'

package 'unity-lens-shopping' do
  action :remove
end

package 'unity-scope-video-remote' do
  action :remove
end

package 'unity-scope-musicstores' do
  action :remove
end

package 'python-gpgme' # for dropbox

package 'radiotray'

package 'vlc'
package 'smplayer'
package 'w64codecs'
package 'libdvdcss2'

package 'network-manager-vpnc'
package 'network-manager-openvpn'

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

# ========== audio

package 'mpd'
package 'mpc'
package 'ncmpc'
package 'sonata'
package 'audacious'
package 'deadbeef'
package 'audacity'
package 'flac'

# ========== System tools

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
package 'fuse-exfat'
package 'autofs'

package 'apparmor-utils'
package 'apparmor-profiles'
package 'apparmor-notify'

execute "enable apparmor firefox profile" do
  command 'aa-enforce /etc/apparmor.d/usr.bin.firefox'
  not_if "aa-status | grep firefox"
end

package 'logrotate'
package 'checkinstall'

#execute 'restart pgld' do
#  command 'pglcmd restart'
#  action :nothing
#end

#package 'pgld'
# brings popup, needs interactive console

# ========== infrared remote
package 'lirc'
package 'evtest'

# ========== power management

package 'powertop'
package 'powertop-1.13'
package 'fatrace'
package 'smartmontools'
package 'iotop'
package 'dstat'
package 'lm-sensors'
package 'xsensors'
#package 'cpufrequtils'
package 'uswsusp'
package 'ethtool'
package 'dconf-tools'
package 'acpi'

# ========== emulators / virtualization

package 'dosbox'
package 'wine'
package 'wine-gecko1.4'

package 'virtualbox'
package 'vagrant'

# ========== color management

package 'argyll'
package 'gnome-color-manager'

# ========== synergy

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
