# Cookbook Name:: woodenbits
# Recipe:: sys-repos

execute "update apt" do
  command 'apt-get -q -y update'
  action :nothing
end

codename = node[:lsb][:codename]

execute "enable partners repo" do
  command 'apt-add-repository --yes "deb http://archive.canonical.com/ $(lsb_release -sc) partner"'
  notifies :run, 'execute[update apt]', :immediately
  not_if %q(grep -e '^deb.\+partner' /etc/apt/sources.list)
end

# not required anumore in "14.04"
execute "enable chrome repo" do
  command %Q(
    wget -q "https://dl-ssl.google.com/linux/linux_signing_key.pub" -O- | sudo apt-key add -
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
  )

  notifies :run, 'execute[update apt]', :immediately
  creates "/etc/apt/sources.list.d/google.list"
  #not_if %q(grep -e '^deb.\+chrome' /etc/apt/sources.list)
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
].each do |ppa_name|
  file_name = ppa_name.sub('/', '-ubuntu-')
  execute "enable #{ppa_name} repo" do
    command "apt-add-repository --yes ppa:#{ppa_name}"
    notifies :run, 'execute[update apt]', :immediately
    creates "/etc/apt/sources.list.d/#{file_name}-#{codename}.list"
  end
end
