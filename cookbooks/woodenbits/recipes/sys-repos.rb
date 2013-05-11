# Cookbook Name:: woodenbits
# Recipe:: sys-repos

execute "update apt" do
  command 'apt-get -q -y update'
  action :nothing
end

execute "enable partners repo" do
  command 'apt-add-repository --yes "deb http://archive.canonical.com/ $(lsb_release -sc) partner"'
  notifies :run, 'execute[update apt]', :immediately
  not_if %q(grep -e '^deb.\+partner' /etc/apt/sources.list)
end

execute "enable medibuntu repo" do
  command %Q(
    wget -q "http://packages.medibuntu.org/medibuntu-key.gpg" -O- | sudo apt-key add -
    add-apt-repository --yes "deb http://packages.medibuntu.org/ $(lsb_release -sc) free non-free"
  )

  notifies :run, 'execute[update apt]', :immediately
  not_if %q(grep -e '^deb.\+medibuntu' /etc/apt/sources.list)
end

execute "enable chrome repo" do
  command %Q(
    wget -q "https://dl-ssl.google.com/linux/linux_signing_key.pub" -O- | sudo apt-key add -
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
  )

  notifies :run, 'execute[update apt]', :immediately
  creates "/etc/apt/sources.list.d/google.list"
  #not_if %q(grep -e '^deb.\+chrome' /etc/apt/sources.list)
end

%w(jre-phoenix/ppa alexeftimie/ppa scopes-packagers/ppa atareao/atareao
   tsbarnes/indicator-keylock eugenesan/ppa rye/ubuntuone-extras
   webupd8team/java relan/exfat starws-box/deadbeef-player).each do |ppa_name|
  file_name = ppa_name.sub('/', '-')
  execute "enable #{ppa_name} repo" do
    command "apt-add-repository --yes ppa:#{ppa_name}"
    notifies :run, 'execute[update apt]', :immediately
    creates "/etc/apt/sources.list.d/#{file_name}-precise.list"
  end
end
