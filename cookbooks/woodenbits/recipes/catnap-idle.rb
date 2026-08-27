# Cookbook Name:: woodenbits
# Recipe:: catnap-idle
#
# Manages the automatic user-session idle watchdog for the catnap suite.
# When enabled (node['woodenbits']['catnap']['idle'] == true):
#   - Deploys and starts the systemd user service catnap-idle.service.
#   - Disables GNOME's own idle auto-suspend settings so catnap takes over.
# When disabled (node['woodenbits']['catnap']['idle'] == false):
#   - Stops/disables catnap-idle.service and removes unit/service files.
#   - Leaves GNOME's idle settings untouched for the user to manage.

sudo_username = ENV.fetch('SUDO_USER') { raise 'SUDO_USER environment variable is required to determine the interactive desktop user' }

unless node[:etc][:passwd].key?(sudo_username)
  raise "SUDO_USER '#{sudo_username}' not found in /etc/passwd"
end

home_dir = "/home/#{sudo_username}"
user_group = `id --group --name #{sudo_username}`.chomp
user_uid = `id --user #{sudo_username}`.chomp

sudo = "sudo -H -u #{sudo_username} env XDG_RUNTIME_DIR=/run/user/#{user_uid} DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/#{user_uid}/bus /bin/bash -c"

  # Clean up legacy watcher name
  file "#{home_dir}/shed/catnap-idle-watcher" do
    action :delete
  end

  execute "reload systemd user daemon for catnap-idle #{sudo_username}" do
    command "systemctl --user -M #{sudo_username}@ daemon-reload"
    action :nothing
  end

  execute "restart catnap-idle for #{sudo_username}" do
    command "systemctl --user -M #{sudo_username}@ restart catnap-idle.service"
    action :nothing
  end

  if node['woodenbits']['catnap']['idle']
    # --- ENABLED STATE ---

    %w(sleep-inactive-ac-type sleep-inactive-battery-type).each do |setting|
      execute "disable gnome idle suspend #{setting} for user #{sudo_username}" do
        command %Q(#{sudo} "gsettings set org.gnome.settings-daemon.plugins.power #{setting} 'nothing'")
        not_if %Q(#{sudo} "gsettings get org.gnome.settings-daemon.plugins.power #{setting} | grep -q 'nothing'")
      end
    end

    template "#{home_dir}/shed/catnap-idle-service" do
      source 'home/shed/catnap-idle-service.erb'
      mode '0700'
      owner sudo_username
      group user_group
      notifies :run, "execute[restart catnap-idle for #{sudo_username}]", :delayed
    end

    directory "#{home_dir}/.config/systemd/user" do
      owner sudo_username
      group user_group
      mode '0755'
      recursive true
    end

    template "#{home_dir}/.config/systemd/user/catnap-idle.service" do
      source 'home/conf/catnap-idle.service.erb'
      owner sudo_username
      group user_group
      mode '0644'
      notifies :run, "execute[reload systemd user daemon for catnap-idle #{sudo_username}]", :immediately
      notifies :run, "execute[restart catnap-idle for #{sudo_username}]", :delayed
    end

    execute "enable and start catnap-idle.service for #{sudo_username}" do
      command "systemctl --user -M #{sudo_username}@ daemon-reload && systemctl --user -M #{sudo_username}@ enable --now catnap-idle.service"
      not_if "systemctl --user -M #{sudo_username}@ is-active catnap-idle.service"
    end
  else
    # --- DISABLED STATE (Clean up services, leave GNOME settings alone) ---

    execute "stop and disable catnap-idle.service for #{sudo_username}" do
      command "systemctl --user -M #{sudo_username}@ disable --now catnap-idle.service"
      only_if "systemctl --user -M #{sudo_username}@ is-active catnap-idle.service || systemctl --user -M #{sudo_username}@ is-enabled catnap-idle.service"
    end

    file "#{home_dir}/.config/systemd/user/catnap-idle.service" do
      action :delete
      notifies :run, "execute[reload systemd user daemon for catnap-idle #{sudo_username}]", :immediately
    end

    file "#{home_dir}/shed/catnap-idle-service" do
      action :delete
    end
  end
