# Cookbook Name:: woodenbits
# Recipe:: sys-packages

# maybe useful kernel options: i915.i915_enable_fbc=1 i915.lvds_downclock=1

include_recipe 'woodenbits::truecrypt'
include_recipe 'woodenbits::audio-packages'
include_recipe 'woodenbits::photo-packages'

# ========== user tools

#package 'skype'
#package 'xournal'
package 'gimp'

unless node[:hostname] == 'opoplavsky-wsl'
  package 'calibre'
  package 'deluge'

  # ========== infrared remote
  package 'lirc'
  package 'evtest'

  # multiverse repo
  package 'dvdrip'
  package 'rar'
end


package 'google-chrome-stable'
package 'chromium-browser'

#package 'python-gpgme' # for dropbox
#package 'nautilus-dropbox'

package 'vlc'
package 'smplayer'
#package 'w64codecs'
#package 'libdvdcss2'

#package 'network-manager-vpnc'
#package 'network-manager-openvpn'

#package 'gnome-sushi' # preview on SPACE
package 'txt2tags'
package 'htmldoc'
package 'youtube-dl'

# ========== emulators / virtualization

#package 'dosbox'
#package 'wine'
#package 'wine-gecko'

# ========== synergy

#package 'synergy' do
#  action :remove
#  only_if "synergyc --version | grep '1.3.8'"
#end

#bash 'install synergy' do
#  version = '1.3.7' # 1.3.8.generates core dumps
#  #arch = 'i686'
#  arch = 'x86_64'
#  cwd '/tmp'
#  code <<-EOH
#    cd /root/install
#    wget http://synergy.googlecode.com/files/synergy-#{version}-Linux-#{arch}.deb
#    sudo dpkg --install synergy-#{version}-Linux-#{arch}.deb
#    sudo apt-mark hold synergy
#    rm synergy-#{version}-Linux-#{arch}.deb
#  EOH
#  creates '/usr/bin/synergyc'
#end
