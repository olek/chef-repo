# Cookbook Name:: woodenbits
# Recipe:: catnap-powerbtn
#
# Physical power-button -> catnap wiring: acpid catches the power button and
# triggers a catnap, logind is told not to act on it, and GNOME's own
# power-button action is disabled so the desktop does not also react.
#
# Laptop hardware integration, opted into per node via run_list. Extends the
# basic system layer (woodenbits::catnap).

include_recipe 'woodenbits::catnap'

package 'acpid'

directory '/etc/systemd/logind.conf.d' do
  owner 'root'
  group 'root'
  mode '0755'
end

execute 'reload logind for catnap' do
  command 'systemctl kill -s HUP systemd-logind'
  action :nothing
end

template '/etc/systemd/logind.conf.d/01-catnap.conf' do
  source 'system/etc/systemd/logind.conf.d-01-catnap.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[reload logind for catnap]', :immediately
end

directory '/etc/acpi/events' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

template '/etc/acpi/events/catnap-powerbtn' do
  source 'system/etc/acpi-events-catnap-powerbtn.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[acpid]', :delayed
end

service 'acpid' do
  action [:enable, :start]
end

# Stop GNOME from acting on the power button itself, so acpid's catnap handler
# is the only thing that responds to it. Per-user, for the invoking desktop user.
sudo_username = ENV.fetch('SUDO_USER')

if node[:etc][:passwd].key?(sudo_username)
  user_uid = `id --user #{sudo_username}`.chomp
  sudo = "sudo -H -u #{sudo_username} env XDG_RUNTIME_DIR=/run/user/#{user_uid} DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/#{user_uid}/bus /bin/bash -c"

  execute "disable default power button action for user #{sudo_username}" do
    command %Q(#{sudo} "gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'nothing'")
    not_if %Q(#{sudo} "gsettings get org.gnome.settings-daemon.plugins.power power-button-action | grep -q 'nothing'")
  end
end
