# Cookbook Name:: woodenbits
# Recipe:: truecrypt

#truecrypt_archive = 'truecrypt_7.1a_console_i386.tar.gz'
truecrypt_archive = 'truecrypt_7.1a_amd64.tar.gz'
cookbook_file "/root/install/#{truecrypt_archive}" do
  source truecrypt_archive
  mode 0640
end

bash 'install truecrypt' do
  cwd '/'
  code <<-EOH
    tar xfz /root/install/#{truecrypt_archive}
  EOH
  creates '/usr/bin/truecrypt'
end

execute 'register truecrypt hook' do
  command 'update-rc.d truecrypt-dismount stop 30 0 6 .'
  action :nothing
end

template '/etc/init.d/truecrypt-dismount' do
  source 'system/etc/init.d.truecrypt.erb'
  mode 0755
  owner 'root'
  group 'root'
  notifies :run, 'execute[register truecrypt hook]', :immediately
end
