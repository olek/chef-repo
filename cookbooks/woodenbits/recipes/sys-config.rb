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

template "/etc/udev/rules.d/59-vial.rules" do
  source "system/etc/udev-rules.d-59-vial.rules.erb"
  mode 0644
  owner 'root'
  group 'root'

  notifies :run, 'execute[reload udev]', :delayed
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

%w(vims vimt manage-gnome-shell cpu-epp-set).each do |script|
  template "/usr/local/bin/#{script}" do
    source "system/usr/local/bin/#{script}.erb"
    mode '0755'
  end
end

username = node[:hostname].start_with?('opoplavsky-') ? 'opoplavsky' : 'olek'

template "/usr/share/polkit-1/actions/cpu.epp.set.policy" do
  source 'system/usr/share-polkit-1-actions-cpu.epp.set.policy.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

file "/etc/polkit-1/rules.d/10-cpu-epp.rules" do
  action :delete
end

file "/home/#{username}/bin/cpu-epp-set" do
  action :delete
end
