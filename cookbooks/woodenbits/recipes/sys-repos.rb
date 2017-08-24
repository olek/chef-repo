# Cookbook Name:: woodenbits
# Recipe:: sys-repos

execute "update apt" do
  command 'apt-get -q -y update'
  action :nothing
end

codename = node[:lsb][:codename]
canonical_host = "http://archive.canonical.com/ubuntu"
main_repo_host = "http://us.archive.ubuntu.com/ubuntu"
src_dir = "/etc/apt/sources.list.d"

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
    echo "deb #{canonical_host} #{codename} partner" >> #{filename}
    chmod 644 #{filename}
  )

  notifies :run, 'execute[update apt]', :immediately
  creates filename
end

execute "enable chrome repo" do
  filename = "#{src_dir}/google.list"

  command %Q(
    wget -q "https://dl-ssl.google.com/linux/linux_signing_key.pub" -O- | sudo apt-key add -
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> #{filename}
    chmod 644 #{filename}
  )

  notifies :run, 'execute[update apt]', :immediately
  creates filename
  not_if { ::File.exist?("#{src_dir}/google_chrome_stable.list") }
end

execute "enable brave repo" do
  filename = "#{src_dir}/#{codename}-brave.list"

  command %Q(
    curl https://s3-us-west-2.amazonaws.com/brave-apt/keys.asc | apt-key add -
    echo "deb [arch=amd64] https://s3-us-west-2.amazonaws.com/brave-apt #{codename} main" >> #{filename}
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
  'jre-phoenix/ppa', # PeerGuardian, not yet for 14.10, force it to be 'trusty' in its apt file for now
  # 'scopes-packagers/ppa', # calculator scope, not yet for 14.10
  'webupd8team/java', # java
  'starws-box/deadbeef-player', # deadbeef music player
#  'pmjdebruijn/gnome-color-manager-release', # new argyll, not yet for 14.10
#  'noobslab/indicators', # indicator-sysmonitor - not for "14.04" yet
  'dhor/myway', # Photography tools
  'pmjdebruijn/darktable-release', # Fresh darktable
  'mkusb/ppa', # making persistent live usb drives
].each do |ppa_name|
  file_name = ppa_name.sub('/', '-ubuntu-')
  execute "enable #{ppa_name} repo" do
    command "apt-add-repository --yes ppa:#{ppa_name}"
    notifies :run, 'execute[update apt]', :immediately
    creates "/etc/apt/sources.list.d/#{file_name}-#{codename}.list"
  end
end
