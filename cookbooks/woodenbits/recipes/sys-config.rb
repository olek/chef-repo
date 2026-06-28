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

#template "/etc/pm/power.d/000_trifty" do
#  source "system/etc/trifty.erb"
#  mode 0755
#end

#template "/etc/pm/power.d/95hdparm-arm" do
#  source "system/etc/95hdparm-arm.erb"
#  mode 0755
#end

#link "/etc/pm/sleep.d/95hdparm-arm" do
#  to "/etc/pm/power.d/95hdparm-arm"
#end

if hostname == 'tenebrus'
  template "/etc/network/if-up.d/wifi-powerman-off" do
    source "system/etc/wifi-powerman-off.erb"
    mode 0755
  end

  template "/etc/modprobe.d/wlan.conf" do
    source "system/etc/modprobe.wlan.conf.erb"
    mode 0644
  end

  execute "enable ExpressCard SATA adapter" do
    command 'echo "acpiphp" >> /etc/modules'
    not_if %q(grep -e '^acpiphp' /etc/modules)
  end
end

template "/usr/local/bin/resize.rb" do
  source 'resize.rb.erb'
  mode '0755'
  owner 'root'
  group 'root'
end

template "/usr/local/bin/tmuxstart" do
  source 'tmuxstart.erb'
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
    source "system/etc/systemd/gnome-shell-#{name}-service.erb"
    mode 0644
    owner 'root'
    group 'root'

    notifies :run, 'execute[reload systemd]', :delayed
  end

end

template "/etc/udev/rules.d/59-vial.rules" do
  source "system/etc/udev-rules.d/59-vial.rules.erb"
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
      source "system/etc/pgl-#{fname}.erb"
      mode 0644
      owner 'root'
      group 'root'
    end
  end

  # TODO figure out what to do with sleep configuration
  # for now, disable customization
  #template "/etc/pm/config.d/00_sleep" do
  #  source "system/etc/pm-config.erb"
  #  mode 0755
  #end

  template "/etc/sysctl.d/60-local.conf" do
    source "system/etc/sysctl.d.conf.erb"
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
  source "system/etc/ncmpc.config.erb"
  mode 0644
end

%w(vims vimt manage-gnome-shell).each do |script|
  template "/usr/local/bin/#{script}" do
    source "system/usr/local-bin/#{script}.erb"
    mode '0755'
  end
end

template "/usr/share/polkit-1/actions/cpu.epp.set.policy" do
  source 'system/usr/polkit-cpu.epp.set.policy.erb'
  variables(
    :username => node[:hostname].start_with?('opoplavsky-') ? 'opoplavsky' : 'olek'
  )
  mode '0640'
end

=begin
#package 'thermald'
#package 'tlp'

package 'laptop-mode-tools'
%w(
ac97-powersave auto-hibernate battery-level-polling bluetooth configuration-file-control
cpufreq dpms-standby eee-superhe ethernet exec-commands hal-polling intel-hda-powersave
intel-sata-powermgmt lcd-brightness nmi-watchdog runtime-pm sched-mc-power-savings
sched-smt-power-savings start-stop-programs terminal-blanking usb-autosuspend video-out
wireless-ipw-power wireless-iwl-power wireless-power
).each do |name|
  template "/etc/laptop-mode/conf.d/#{name}.conf" do
    source "system/etc/laptop-mode.conf.d/#{name}.conf"
    mode 0644
  end
end
=end
