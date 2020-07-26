# Cookbook Name:: woodenbits
# Recipe:: sys-repos

execute "update apt" do
  command 'apt-get -q -y update'
  action :nothing
end

codename = node[:lsb][:codename]
platform_version=node[:platform_version]
canonical_host = "http://archive.canonical.com/ubuntu"
main_repo_host = "http://us.archive.ubuntu.com/ubuntu"
src_dir = "/etc/apt/sources.list.d"

package 'curl' # dependency, some repos can not be configured without curl

execute "enable partners repo" do
  filename = "#{src_dir}/#{codename}-partner.list"

  command %Q(
    echo "deb #{canonical_host} #{codename} partner" >> #{filename}
    chmod 644 #{filename}
  )

  notifies :run, 'execute[update apt]', :immediately
  creates filename
end

execute "enable multiverse repo" do
  filename = "#{src_dir}/#{codename}-multiverse.list"

  command %Q(
    echo "deb #{main_repo_host} #{codename} multiverse" >> #{filename}
    echo "deb #{main_repo_host} #{codename}-updates multiverse" >> #{filename}
    chmod 644 #{filename}
  )

  notifies :run, 'execute[update apt]', :immediately
  creates filename
end

# Google repo seems to be available in default install since 17.04 ? Maybe not.
execute "enable chrome repo" do
  filename = "#{src_dir}/google-chrome.list"

  command %Q(
    wget -q "https://dl-ssl.google.com/linux/linux_signing_key.pub" -O- | sudo apt-key add -
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> #{filename}
    chmod 644 #{filename}
  )

  notifies :run, 'execute[update apt]', :immediately
  creates filename
#  not_if { ::File.exist?("#{src_dir}/google_chrome_stable.list") }
end

execute "enable google talk repo" do
  filename = "#{src_dir}/google-talk.list"

  command %Q(
    wget -q "https://dl-ssl.google.com/linux/linux_signing_key.pub" -O- | sudo apt-key add -
    echo "deb http://dl.google.com/linux/talkplugin/deb/ stable main" >> #{filename}
    chmod 644 #{filename}
  )

  notifies :run, 'execute[update apt]', :immediately
  creates filename
  not_if { ::File.exist?("#{src_dir}/google_talk_stable.list") }
end

execute "enable brave repo" do
  filename = "#{src_dir}/#{codename}-brave.list"

  command %Q(
    curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
    echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ #{codename} main" >> #{filename}
    chmod 644 #{filename}
  )

  notifies :run, 'execute[update apt]', :immediately
  creates filename
end

execute "enable docker repo" do
  filename = "#{src_dir}/#{codename}-docker.list"

  command %Q(
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu #{codename} stable" >> #{filename}
    chmod 644 #{filename}
  )

  notifies :run, 'execute[update apt]', :immediately
  creates filename
end

execute "enable insomnia repo" do
  filename = "#{src_dir}/#{codename}-insomnia.list"

  command %Q(
    curl https://insomnia.rest/keys/debian-public.key.asc | apt-key add -
    echo "deb [arch=amd64] https://dl.bintray.com/getinsomnia/Insomnia /" >> #{filename}
    chmod 644 #{filename}
  )

  notifies :run, 'execute[update apt]', :immediately
  creates filename
end

execute "enable darktable repo" do
  filename = "#{src_dir}/#{codename}-darktable.list"

  command %Q(
    curl -fsSL https://download.opensuse.org/repositories/graphics:darktable/xUbuntu_#{platform_version}/Release.key | apt-key add -
    echo "deb http://download.opensuse.org/repositories/graphics:/darktable/xUbuntu_#{platform_version}/ /" >> #{filename}
    chmod 644 #{filename}
  )

  notifies :run, 'execute[update apt]', :immediately
  creates filename
end

# it is better to pick up dropbox from multiverse repo
#execute "enable dropbox repo" do
#  command %Q(
#    apt-key adv --keyserver pgp.mit.edu --recv-keys 5044912E
#    echo "deb http://linux.dropbox.com/ubuntu #{codename} main" >> /etc/apt/sources.list.d/#{codename}-dropbox.list
#  )
#  notifies :run, 'execute[update apt]', :immediately
#  creates "/etc/apt/sources.list.d/#{codename}-dropbox.list"
#end

#   eugenesan/ppa
#   ppa:pmjdebruijn/gnome-color-manager-release
[
  'flacon/ppa', # flacon, splitting flac and ape files
  'jre-phoenix/ppa', # PeerGuardian, last available version is for yakkety, force it to that in apt file
  # 'scopes-packagers/ppa', # calculator scope, not yet for 14.10
  # 'webupd8team/java', # oracle java8, discontinued in 19.10 eoan
  'starws-box/deadbeef-player', # deadbeef music player
#  'pmjdebruijn/gnome-color-manager-release', # new argyll, not yet for 14.10
#  'noobslab/indicators', # indicator-sysmonitor - not for "14.04" yet
  'dhor/myway', # Photography tools
  #'pmjdebruijn/darktable-release', # Fresh darktable - not available yet for 19.10 eoan
].each do |ppa_name|
  file_name = ppa_name.sub('/', '-ubuntu-')
  execute "enable #{ppa_name} repo" do
    command "apt-add-repository --yes ppa:#{ppa_name}"
    notifies :run, 'execute[update apt]', :immediately
    creates "/etc/apt/sources.list.d/#{file_name}-#{codename}.list"
  end
end
