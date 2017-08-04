# Cookbook Name:: woodenbits
# Recipe:: sys-repos

execute "update apt" do
  command 'apt-get -q -y update'
  action :nothing
end

codename = node[:lsb][:codename]
canonical_host = "http://archive.canonical.com/ubuntu"
src_dir = "/etc/apt/sources.list.d"

execute "enable partners repo" do
  command %Q(
    echo "deb #{canonical_host} #{codename} partner" >> #{src_dir}/#{codename}-partner.list
  )

  notifies :run, 'execute[update apt]', :immediately
  creates "/etc/apt/sources.list.d/#{codename}-partner.list"
end

execute "enable chrome repo" do
  command %Q(
    wget -q "https://dl-ssl.google.com/linux/linux_signing_key.pub" -O- | sudo apt-key add -
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
  )

  notifies :run, 'execute[update apt]', :immediately
  creates "/etc/apt/sources.list.d/google.list"
  not_if { ::File.exist?('/etc/apt/sources.list.d/google_chrome_stable.list') }
end

#   eugenesan/ppa
#   ppa:pmjdebruijn/gnome-color-manager-release
[
  'flacon/ppa', # flacon, splitting flac and ape files
  'jre-phoenix/ppa', # PeerGuardian, not yet for 14.10, force it to be 'trusty' in its apt file for now
  # 'scopes-packagers/ppa', # calculator scope, not yet for 14.10
  'webupd8team/java', # java
  'starws-box/deadbeef-player', # deadbeef music player
#  'pmjdebruijn/gnome-color-manager-release', # new argyll, not yet for 14.10
#  'noobslab/indicators', # indicator-sysmonitor - not for "14.04" yet
  'dhor/myway', # Photography tools
  'pmjdebruijn/darktable-release', # Fresh darktable
].each do |ppa_name|
  file_name = ppa_name.sub('/', '-ubuntu-')
  execute "enable #{ppa_name} repo" do
    command "apt-add-repository --yes ppa:#{ppa_name}"
    notifies :run, 'execute[update apt]', :immediately
    creates "/etc/apt/sources.list.d/#{file_name}-#{codename}.list"
  end
end
