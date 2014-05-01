# Cookbook Name:: woodenbits
# Recipe:: sys-config

#Chef::Log.info "fqdn = #{node[:fqdn]}, hostname = #{node[:hostname]}"

directory '/etc/pgl' do
  mode '0755'
  action :create
end

directory '/vaults' do
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

execute "turn off chef-client verbose logging" do
  command "echo 'verbose_logging false' >> /etc/chef/client.rb"
  not_if "grep 'verbose_logging false' /etc/chef/client.rb"
end

template "/etc/pm/power.d/000_trifty" do
  source "system/etc/trifty.erb"
  mode 0755
end

template "/etc/pm/sleep.d/05_wake_up_network_manager_hack" do
  source "system/etc/wake_up_network_manager_hack.erb"
  mode 0755
end

template "/etc/modprobe.d/wlan.conf" do
  source "system/etc/modprobe.wlan.conf.erb"
  mode 0644
end

template "/usr/local/bin/adjust-scroll" do
  source 'adjust-scroll.erb'
  mode '0755'
  owner 'root'
  group 'root'
end

template "/usr/local/bin/resize.rb" do
  source 'resize.rb.erb'
  mode '0755'
  owner 'root'
  group 'root'
end

template "/etc/pm/config.d/00_sleep" do
  source "system/etc/pm-config.erb"
  mode 0755
end

template "/etc/sysctl.d/60-local.conf" do
  source "system/etc/sysctl.d.conf.erb"
  mode 0644
end

directory '/etc/auto.master.d' do
  mode '0755'
  action :create
end

template "/etc/auto.cifs" do
  source "system/etc/auto.cifs.erb"
  mode 0755
end

template "/etc/auto.master.d/cifs.autofs" do
  source "system/etc/cifs.autofs.erb"
  mode 0644
end

%w(svim tvim).each do |script|
  template "/usr/local/bin/#{script}" do
    source "system/usr/local/#{script}.erb"
    mode '0755'
  end
end

execute "enable ExpressCard SATA adapter" do
  command 'echo "acpiphp" >> /etc/modules'
  not_if %q(grep -e '^acpiphp' /etc/modules)
end

=begin
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
