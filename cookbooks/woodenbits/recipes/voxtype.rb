# Cookbook Name:: woodenbits
# Recipe:: voxtype

voxtype_version = '0.7.1'
voxtype_deb_filename = "voxtype_#{voxtype_version}-1_amd64.deb"
voxtype_deb_path = "#{Chef::Config[:file_cache_path]}/#{voxtype_deb_filename}"

# Install packages
package 'ydotool'
package 'ydotoold'
package 'libnotify-bin'

# Ensure ydotool group exists and has members
group 'ydotool' do
  members ['olek', 'opoplavsky'].select { |u| node[:etc][:passwd].key?(u) }
  append true
  action :create
end

# Ensure system user 'ydotool' exists
user 'ydotool' do
  system true
  shell '/bin/false'
  group 'ydotool'
  action :create
end

# Ensure uinput group exists and has members
group 'uinput' do
  members (['ydotool'] + ['olek', 'opoplavsky'].select { |u| node[:etc][:passwd].key?(u) })
  append true
  action :create
end

# Ensure workstation users are in input group
group 'input' do
  members ['olek', 'opoplavsky'].select { |u| node[:etc][:passwd].key?(u) }
  append true
  action :modify
end

# Manage udev rule for uinput
file '/etc/udev/rules.d/99-uinput.rules' do
  content 'KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[reload-udev-rules]', :immediately
end

execute 'reload-udev-rules' do
  command 'udevadm control --reload-rules && udevadm trigger'
  action :nothing
end

# Manage log file
file '/var/log/ydotool.log' do
  owner 'root'
  group 'ydotool'
  mode '0644'
  action :create
end

# Manage logrotate for ydotool
file '/etc/logrotate.d/ydotool' do
  content <<~EOF
    /var/log/ydotool.log {
        daily
        rotate 7
        compress
        missingok
        notifempty
        copytruncate
    }
  EOF
  owner 'root'
  group 'root'
  mode '0644'
end

# Manage systemd service /etc/systemd/system/ydotoold.service
file '/etc/systemd/system/ydotoold.service' do
  content <<~EOF
    [Unit]
    Description=ydotoold - ydotool daemon
    Documentation=https://github.com/ReimuNotMoe/ydotool
    Wants=modprobe@uinput.service
    After=modprobe@uinput.service local-fs.target

    [Service]
    Type=simple
    User=ydotool
    Group=ydotool
    ExecStartPre=+/bin/rm -f /tmp/.ydotool_socket
    ExecStart=/usr/bin/ydotoold
    ExecStartPost=/bin/sleep 0.5
    ExecStartPost=/bin/chmod 0660 /tmp/.ydotool_socket
    ExecStop=+/bin/rm -f /tmp/.ydotool_socket
    StandardOutput=append:/var/log/ydotool.log
    StandardError=append:/var/log/ydotool.log
    Restart=on-failure

    # Security hardening
    DeviceAllow=/dev/uinput rw
    DevicePolicy=closed
    LockPersonality=true
    NoNewPrivileges=true
    PrivateNetwork=true
    ProtectHome=true
    ProtectHostname=true
    ProtectKernelTunables=true
    ProtectKernelModules=true
    ProtectKernelLogs=true
    ProtectSystem=full
    ProtectControlGroups=true
    RestrictAddressFamilies=AF_UNIX
    RestrictNamespaces=true
    SystemCallArchitectures=native
    RestrictSUIDSGID=true
    RestrictRealtime=true
    RemoveIPC=true
    IPAddressDeny=any

    [Install]
    WantedBy=multi-user.target
  EOF
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[ydotoold-systemctl-daemon-reload]', :immediately
end

execute 'ydotoold-systemctl-daemon-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

# Enable and start ydotoold service
service 'ydotoold' do
  action [:enable, :start]
end

# Download the Voxtype debian package
remote_file voxtype_deb_path do
  source "https://github.com/peteonrails/voxtype/releases/download/v#{voxtype_version}/#{voxtype_deb_filename}"
  mode '0644'
  action :create
end

# Install Voxtype package
dpkg_package 'voxtype' do
  source voxtype_deb_path
  action :install
end

# Find existing users on this machine
target_users = ['olek', 'opoplavsky'].select { |u| node[:etc][:passwd].key?(u) }

target_users.each do |user|
  home_dir = "/home/#{user}"
  user_group = `id --group --name #{user}`.chomp

  # Ensure user config directories exist
  [
    "#{home_dir}/.config",
    "#{home_dir}/.config/voxtype"
  ].each do |dir|
    directory dir do
      owner user
      group user_group
      mode '0750'
      action :create
    end
  end

  # Deploy Voxtype configuration file
  template "#{home_dir}/.config/voxtype/config.toml" do
    source 'home/conf/voxtype-config.toml.erb'
    owner user
    group user_group
    mode '0640'
    notifies :run, "execute[restart-voxtype-service-for-#{user}]", :delayed
  end

  # Download the Whisper medium.en model using voxtype CLI
  execute "download-whisper-model-for-#{user}" do
    command "sudo -i -u #{user} voxtype setup --download --model medium.en"
    creates "#{home_dir}/.local/share/voxtype/models/ggml-medium.en.bin"
  end

  # Run voxtype systemd setup to generate the default systemd user service
  execute "setup-systemd-service-for-#{user}" do
    command "sudo -i -u #{user} voxtype setup systemd"
    creates "#{home_dir}/.config/systemd/user/voxtype.service"
  end

  # Ensure user service override folder exists
  directory "#{home_dir}/.config/systemd/user/voxtype.service.d" do
    owner user
    group user_group
    mode '0750'
    recursive true
    action :create
  end

  # Deploy verbose logging drop-in config
  template "#{home_dir}/.config/systemd/user/voxtype.service.d/verbose.conf" do
    source 'home/conf/voxtype-verbose.conf.erb'
    owner user
    group user_group
    mode '0640'
    notifies :run, "execute[restart-voxtype-service-for-#{user}]", :delayed
  end

  # Deploy restart policy drop-in config
  template "#{home_dir}/.config/systemd/user/voxtype.service.d/restart.conf" do
    source 'home/conf/voxtype-restart.conf.erb'
    owner user
    group user_group
    mode '0640'
    notifies :run, "execute[restart-voxtype-service-for-#{user}]", :delayed
  end

  # Helper resource to restart the user-level daemon
  execute "restart-voxtype-service-for-#{user}" do
    command "systemctl --user -M #{user}@ daemon-reload && systemctl --user -M #{user}@ restart voxtype"
    action :nothing
  end

  # Enable and run Voxtype user service
  execute "enable-and-start-voxtype-for-#{user}" do
    command "systemctl --user -M #{user}@ daemon-reload && systemctl --user -M #{user}@ enable --now voxtype"
    action :run
    not_if "systemctl --user -M #{user}@ is-active voxtype"
  end
end
