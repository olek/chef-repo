# Cookbook Name:: woodenbits
# Recipe:: sys-config

#Chef::Log.info "fqdn = #{node[:fqdn]}, hostname = #{node[:hostname]}"

if node[:platform] == 'ubuntu' && node[:platform_version] == '12.04'
  template '/etc/polkit-1/localauthority/50-local.d/com.ubuntu.enable-hibernate.pkla' do
    source 'com.ubuntu.enable-hibernate.pkla.erb'
    mode 0644
    owner 'root'
    group 'root'
  end
end

directory '/etc/pgl' do
  mode '0755'
  action :create
end

%w(pglcmd.conf blocklists.list).each do |fname|
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

template "/etc/pm/config.d/00_sleep" do
  source "system/etc/pm-config.erb"
  mode 0755
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
