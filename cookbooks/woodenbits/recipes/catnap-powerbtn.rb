# Cookbook Name:: woodenbits
# Recipe:: catnap-powerbtn
#
# Manages physical power button -> catnap integration.
# When enabled (node['woodenbits']['catnap']['powerbtn'] == true):
#   - Installs acpid and catnap-powerbtn event handler.
#   - Configures logind drop-in to ignore power button.
#   - Disables GNOME's power-button-action so desktop does not act on it.
# When disabled (node['woodenbits']['catnap']['powerbtn'] == false):
#   - Removes logind and acpid drop-in configurations.
#   - Leaves GNOME's power button action untouched for the user to manage.

execute 'reload logind for catnap' do
  command 'systemctl kill -s HUP systemd-logind'
  action :nothing
end

if node['woodenbits']['catnap']['powerbtn']
  # --- ENABLED STATE ---

  sudo_username = ENV.fetch('SUDO_USER') { raise 'SUDO_USER environment variable is required to determine the interactive desktop user' }

  unless node[:etc][:passwd].key?(sudo_username)
    raise "SUDO_USER '#{sudo_username}' not found in /etc/passwd"
  end

  package 'acpid'

  directory '/etc/systemd/logind.conf.d' do
    owner 'root'
    group 'root'
    mode '0755'
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

  user_uid = `id --user #{sudo_username}`.chomp
  sudo = "sudo -H -u #{sudo_username} env XDG_RUNTIME_DIR=/run/user/#{user_uid} DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/#{user_uid}/bus /bin/bash -c"

  execute "disable default power button action for user #{sudo_username}" do
    command %Q(#{sudo} "gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'nothing'")
    not_if %Q(#{sudo} "gsettings get org.gnome.settings-daemon.plugins.power power-button-action | grep -q 'nothing'")
  end
else
  # --- DISABLED STATE (Clean up drop-ins, leave GNOME settings alone) ---

  file '/etc/systemd/logind.conf.d/01-catnap.conf' do
    action :delete
    notifies :run, 'execute[reload logind for catnap]', :immediately
  end

  file '/etc/acpi/events/catnap-powerbtn' do
    action :delete
    notifies :restart, 'service[acpid]', :delayed
  end
end
