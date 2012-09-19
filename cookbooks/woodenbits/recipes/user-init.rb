# Cookbook Name:: woodenbits
# Recipe:: user-init

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
    supports :manage_home => true
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

