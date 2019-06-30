# Cookbook Name:: woodenbits
# Recipe:: sys-packages

# maybe useful kernel options: i915.i915_enable_fbc=1 i915.lvds_downclock=1

# ========== essentials

package 'aptitude'

unless node[:hostname] == 'opoplavsky-wsl'
  package 'ubuntu-restricted-extras'
end

package 'build-essential'

# ruby, rake and git should be in dev, but must be here because of damn janus
package 'ruby'
package 'rake'

case node[:platform]
when 'debian', 'ubuntu'
  package 'git-core'
else
  package 'git'
end

# client and server
package 'ssh'

# compile your own kernel
#package 'fakeroot'
#package 'kernel-package'
#package 'linux-source'


# ========== essential user tools

package 'vim-gnome'

package 'compizconfig-settings-manager'
package 'gnome-tweak-tool' # make it possible to remap caps lock to ctrl

package 'screen'
package 'tmux'

package 'wmctrl' # for window resize script resize.rb

[
  'multiload' # not great, but available by default
#  'sysmonitor', # not available for 14.04 yet
#  'ubuntuone' # same
].each do |name|
  package "indicator-#{name}"
end

#package 'unity-lens-utilities'
package 'unity-scope-calculator'
#package 'unity-scope-cities'
#package 'unity-scope-rottentomatoes'

#package 'unity-scope-video-remote' do
#  action :remove
#end

#package 'unity-scope-musicstores' do
#  action :remove
#end

# ========== System tools

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
package 'exfat-fuse'
package 'autofs'
package 'smbclient' # otherwise automount cifs does not work

# NOTE not sure if this apparmor stuff is required anymore, commenting out on 20170727
#package 'apparmor-utils'
#package 'apparmor-profiles'
#package 'apparmor-notify'

#execute "enable apparmor firefox profile" do
#  command 'aa-enforce /etc/apparmor.d/usr.bin.firefox'
#  not_if "aa-status | grep firefox"
#end

package 'logrotate'
package 'checkinstall'
package 'python-pip'

#execute 'restart pgld' do
#  command 'pglcmd restart'
#  action :nothing
#end

#package 'pgld'
# brings popup, needs interactive console

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
#package 'dconf-tools' - not available anymore in 18.10
package 'acpi'
package 'asterisk-core-sounds-en-wav'

# ========== color management

package 'argyll'
package 'dispcalgui'
package 'gnome-color-manager'
