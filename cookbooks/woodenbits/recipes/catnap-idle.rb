# Cookbook Name:: woodenbits
# Recipe:: catnap-idle
#
# Automatic idle trigger for the catnap suite: a user-session watchdog that
# transitions unattended sessions into catnap sleep (instead of disruptive ACPI
# suspend) once GNOME's configured idle timeout is reached, gated on active
# audio streams and session inhibitors.
#
# Extends the basic system layer (woodenbits::catnap) with the per-user pieces,
# so a node opts into idle simply by adding this recipe to its run_list.
#
# The idle watchdog is a GNOME user-session service, so it is installed for the
# invoking desktop user (SUDO_USER) rather than every account on the box.

include_recipe 'woodenbits::catnap'

sudo_username = ENV.fetch('SUDO_USER')

# Only the interactive desktop user gets the idle watchdog; skip system runs
# (e.g. root-only bootstraps) where SUDO_USER is not a real login account.
if node[:etc][:passwd].key?(sudo_username)
  home_dir = "/home/#{sudo_username}"
  user_group = `id --group --name #{sudo_username}`.chomp
  user_uid = `id --user #{sudo_username}`.chomp

  sudo = "sudo -H -u #{sudo_username} env XDG_RUNTIME_DIR=/run/user/#{user_uid} DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/#{user_uid}/bus /bin/bash -c"

  # Disable GNOME's own idle auto-suspend so catnap takes over the idle path
  # instead of racing the desktop's ACPI suspend at the same timeout.
  %w(sleep-inactive-ac-type sleep-inactive-battery-type).each do |setting|
    execute "disable gnome idle suspend #{setting} for user #{sudo_username}" do
      command %Q(#{sudo} "gsettings set org.gnome.settings-daemon.plugins.power #{setting} 'nothing'")
      not_if %Q(#{sudo} "gsettings get org.gnome.settings-daemon.plugins.power #{setting} | grep -q 'nothing'")
    end
  end

  # Clean up the old watcher name (renamed watcher -> service).
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
end
