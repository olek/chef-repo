# Cookbook Name:: woodenbits
# Recipe:: user-init


passwd = node[:etc][:passwd]

if passwd.key?('alpha') && !passwd.key?('opoplavsky') && node[:hostname] != 'opoplavsky-wsl'
  Chef::Log.info "Creating my 4 default users with corrent UIDs"

  users = {
    'olek' => [ 'Olek Poplavsky', 1001 ],
    'lana' => [ 'Svitlana Poplavska', 1002 ],
    'ellen' => [ 'Ellen Poplavska', 1003 ],
    'eric' => [ 'Eric Poplavsky', 1004 ]
  }

  users.each do |user_login, (user_name, user_uid)|
    user user_login do
      action :create
      comment user_name
      uid user_uid if user_uid
      gid 'users'
      home "/home/#{user_login}"
      shell "/bin/bash"
      manage_home true
    end
  end

  group "sudo" do
    action :modify
    members "olek"
    append true
  end

  group "lpadmin" do
    action :modify
    members "olek"
    append true
  end
end
