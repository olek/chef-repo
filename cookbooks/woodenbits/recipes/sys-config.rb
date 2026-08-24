# Cookbook Name:: woodenbits
# Recipe:: sys-config

#Chef::Log.info "fqdn = #{node[:fqdn]}, hostname = #{node[:hostname]}"

hostname = node[:hostname]

directory '/vaults' do
  mode '0755'
  action :create
end

#execute "turn off chef-client verbose logging" do
#  command "echo 'verbose_logging false' >> /etc/cinc/client.rb"
#  not_if "grep 'verbose_logging false' /etc/cinc/client.rb"
#end


if hostname == 'tenebrus'
  template "/etc/network/if-up.d/wifi-powerman-off" do
    source "system/etc/network-if-up.d-wifi-powerman-off.erb"
    mode 0755
  end

  template "/etc/modprobe.d/wlan.conf" do
    source "system/etc/modprobe.d-wlan.conf.erb"
    mode 0644
  end

  execute "enable ExpressCard SATA adapter" do
    command 'echo "acpiphp" >> /etc/modules'
    not_if %q(grep -e '^acpiphp' /etc/modules)
  end
end

template "/usr/local/bin/resize.rb" do
  source 'system/usr/local/bin/resize.rb.erb'
  mode '0755'
  owner 'root'
  group 'root'
end

template "/usr/local/bin/tmuxstart" do
  source 'system/usr/local/bin/tmuxstart.erb'
  mode '0755'
  owner 'root'
  group 'root'
end

execute "reload systemd" do
  command %Q(
    systemctl daemon-reload
    systemctl enable gnome-shell-suspend
    systemctl enable gnome-shell-resume
  )
  action :nothing
end

execute "reload udev" do
  command %Q(
    udevadm control --reload-rules
    udevadm trigger
  )
  action :nothing
end

%w(suspend resume).each do |name|
  template "/etc/systemd/system/gnome-shell-#{name}.service" do
    source "system/etc/systemd/system/gnome-shell-#{name}.service.erb"
    mode 0644
    owner 'root'
    group 'root'

    notifies :run, 'execute[reload systemd]', :delayed
  end

end

template "/etc/udev/rules.d/58-kinesis.rules" do
  source "system/etc/udev/rules.d/58-kinesis.rules.erb"
  mode 0644
  owner 'root'
  group 'root'

  notifies :run, 'execute[reload udev]', :delayed
end

template "/etc/udev/rules.d/59-vial.rules" do
  source "system/etc/udev/rules.d/59-vial.rules.erb"
  mode 0644
  owner 'root'
  group 'root'

  notifies :run, 'execute[reload udev]', :delayed
end


if node[:etc][:passwd].key?('olek')
  # template "/etc/udev/rules.d/99-nvidia-pm-on.rules" do
  #   source "system/etc/udev/rules.d/99-nvidia-pm-on.rules.erb"
  #   mode 0644
  #   owner 'root'
  #   group 'root'
  #
  #   notifies :run, 'execute[reload udev]', :delayed
  # end

  file "/etc/udev/rules.d/99-nvidia-pm-on.rules" do
    action :delete
    notifies :run, 'execute[reload udev]', :delayed
  end
end


unless node[:hostname].start_with?('opoplavsky-')
  directory '/etc/pgl' do
    mode '0755'
    action :create
  end

  %w(pglcmd.conf blocklists.list allow.p2p).each do |fname|
    template "/etc/pgl/#{fname}" do
      source "system/etc/pgl/#{fname}.erb"
      mode 0644
      owner 'root'
      group 'root'
    end
  end


  template "/etc/sysctl.d/60-local.conf" do
    source "system/etc/sysctl.d-60-local.conf.erb"
    mode 0644
  end

  directory '/etc/auto.master.d' do
    mode '0755'
    action :create
  end

  #template "/etc/auto.cifs" do
  #  source "system/etc/auto.cifs.erb"
  #  mode 0755
  #end

  #template "/etc/auto.master.d/cifs.autofs" do
  #  source "system/etc/cifs.autofs.erb"
  #  mode 0644
  #end

  #template "/etc/auto.master.d/smb.autofs" do
  #  source "system/etc/smb.autofs.erb"
  #  mode 0644
  #end

  template "/etc/auto.master.d/net.autofs" do
    source "system/etc/net.autofs.erb"
    mode 0644
  end
end

template "/etc/mpd.conf" do
  source "system/etc/mpd.conf.erb"
  mode 0644
  # avoid installing config before package to avoid conflicts
  only_if { ::File.exist?("/usr/bin/mpd") }
end

directory '/etc/ncmpc' do
  mode '0755'
  action :create
end

template "/etc/ncmpc/config" do
  source "system/etc/ncmpc-config.erb"
  mode 0644
end

%w(vims vimt manage-gnome-shell cpu-epp-set catnap catnap-engine).each do |script|
  template "/usr/local/bin/#{script}" do
    source "system/usr/local/bin/#{script}.erb"
    mode '0755'
  end
end

# Register a handler for gvim:///path/to/file:LINE URLs so the OS can open
# them in GVim via vimt. Rebuild the desktop database when the entry changes.
execute 'update-desktop-database' do
  command 'update-desktop-database /usr/share/applications'
  action :nothing
end

template '/usr/share/applications/gvim-url-handler.desktop' do
  source 'system/usr/share/applications/gvim-url-handler.desktop.erb'
  mode '0644'
  owner 'root'
  group 'root'
  notifies :run, 'execute[update-desktop-database]', :immediately
end

# Delete the old unmanaged setup script
file '/usr/local/bin/nvidia-app-custom-setup-on-boot' do
  action :delete
end

# Deploy the new Nvidia clock tuning scripts
%w(nvidia-minmax-clocks nvidia-min-clocks nvidia-reset-clocks).each do |script|
  template "/usr/local/bin/#{script}" do
    source "system/usr/local/bin/#{script}.erb"
    mode '0755'
    owner 'root'
    group 'root'
  end
end

execute 'nvidia systemd-daemon-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

template '/etc/systemd/system/nvidia-minmax-clocks.service' do
  source 'system/etc/systemd/system/nvidia-minmax-clocks.service.erb'
  mode '0644'
  owner 'root'
  group 'root'
  notifies :run, 'execute[nvidia systemd-daemon-reload]', :immediately
end

service 'nvidia-minmax-clocks' do
  action [:enable, :start]
end

sudo_username = ENV.fetch('SUDO_USER')

template "/usr/share/polkit-1/actions/cpu.epp.set.policy" do
  source 'system/usr/share-polkit-1-actions-cpu.epp.set.policy.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

file "/etc/polkit-1/rules.d/10-cpu-epp.rules" do
  action :delete
end

file "/home/#{sudo_username}/bin/cpu-epp-set" do
  action :delete
end

# TLP power-management tuning, laptop-specific (SK-hynix NVMe, i915 iGPU,
# Raptor Lake HX). Only reloaded when the config changes; the tlp package
# auto-enables its service on install.
if %w(opoplavsky-ltl1 severus).include?(node[:hostname])
  execute 'reload tlp' do
    command 'tlp start'
    action :nothing
  end

  template '/etc/tlp.d/01-woodenbits.conf' do
    source 'system/etc/tlp.d-01-woodenbits.conf.erb'
    owner 'root'
    group 'root'
    # 0644 matches upstream /etc/tlp.conf; contents are power policy, no secrets
    mode '0644'
    variables(
      hostname: node[:hostname]
    )
    notifies :run, 'execute[reload tlp]', :delayed
  end
end

file '/etc/polkit-1/rules.d/50-catnap.rules' do
  action :delete
end

directory '/var/log/catnap' do
  owner 'root'
  group 'root'
  mode '0755'
end

file '/var/log/catnap/catnap.log' do
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

file '/etc/logrotate.d/catnap' do
  content <<~EOF
    /var/log/catnap/catnap.log {
      weekly
      rotate 4
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

template '/etc/sudoers.d/catnap' do
  source 'system/etc/sudoers.d/catnap.erb'
  owner 'root'
  group 'root'
  mode '0440'
end

execute 'reload systemd for catnap' do
  command 'systemctl daemon-reload'
  action :nothing
end

file '/usr/local/sbin/catnap-watcher' do
  action :delete
end

file '/etc/systemd/system/catnap@.service' do
  action :delete
  notifies :run, 'execute[reload systemd for catnap]', :immediately
end

template '/etc/systemd/system/catnap.service' do
  source 'system/etc/systemd/system/catnap.service.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[reload systemd for catnap]', :immediately
end

if node[:hostname] == 'severus'
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
end
