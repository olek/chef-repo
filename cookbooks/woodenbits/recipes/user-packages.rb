# Cookbook Name:: woodenbits
# Recipe:: user-packages

include_recipe 'woodenbits::truecrypt'
include_recipe 'woodenbits::audio-packages'

# ========== user tools

package 'gimp'
package 'xsel'
package 'boxes'
package 'tree'

# webcam adjustments UI
package 'guvcview'
# webcam adjustments loader
package 'uvcdynctrl'

unless node[:hostname].start_with?('opoplavsky-')
  include_recipe 'woodenbits::photo-packages'

  package 'calibre'
  package 'deluge'

  # ========== infrared remote
  # causes lots of errors in syslog, causes tenebrus to freeze after actually using remote
  # package 'lirc'
  package 'evtest'

  # multiverse repo
  # package 'dvdrip' not available anymore in 18.10
  package 'rar'

  package 'txt2tags'
  package 'htmldoc'
  # package 'youtube-dl' - always obsolete, install using curl command

  package 'lilypond' # generating sheet music
  package 'entr' # convenient repeated running of lilypond

  # why would I want docker on non-work computers?
  package 'docker-ce' do
    action :purge
  end
  package 'docker-buildx-plugin' do
    action :purge
  end
end

package 'google-chrome-stable'
package 'chrome-gnome-shell'
package 'chromium-browser'

# new version of brave browser
package 'brave-browser'

package 'signal-desktop'

package 'nautilus-dropbox'

package 'vlc'
package 'smplayer'
#package 'w64codecs'
#package 'libdvdcss2'

package 'gnome-calculator'
package 'gnome-tweaks'
package 'gnome-shell-extensions'
package 'gnome-shell-extension-manager'
#package 'gnome-shell-extension-system-monitor'
#package 'gir1.2-gtop-2.0' # required by system-monitor extension

# ========== emulators / virtualization

#package 'dosbox'
#package 'wine'
#package 'libnss-resolve:i386' # to get DNS resolution to work in Wine for some apps, like EAC
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
