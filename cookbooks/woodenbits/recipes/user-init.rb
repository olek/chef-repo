# Cookbook Name:: woodenbits
# Recipe:: user-init

users = {
  'test1' => [ 'Test Testerovich1', 551 ]
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
#    password '$1$6iXTaWAj$yGo8SzY6QzZfrgxxNwkxG1'
  end
end

