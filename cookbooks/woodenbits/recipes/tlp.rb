# Cookbook Name:: woodenbits
# Recipe:: tlp
#
# Manages TLP power-management tuning for laptops.
# Controlled via:
#   node['woodenbits']['tlp']['enabled']                   (default: false)
#   node['woodenbits']['tlp']['mem_sleep_bat']              (default: 'deep')
#   node['woodenbits']['tlp']['battery_charge_thresholds']  (e.g. { 'start' => 70, 'stop' => 80 })

if node['woodenbits']['tlp']['enabled']
  package 'tlp'

  # power-profiles-daemon fights TLP over EPP / runtime PM; purged 2026-02-09,
  # keep it gone so a GNOME meta-package can't silently pull it back in.
  package 'power-profiles-daemon' do
    action :purge
  end

  execute 'reload tlp' do
    command 'tlp start'
    action :nothing
  end

  template '/etc/tlp.d/01-woodenbits.conf' do
    source 'system/etc/tlp.d-01-woodenbits.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      mem_sleep_bat: node['woodenbits']['tlp']['mem_sleep_bat'],
      charge_thresholds: node['woodenbits']['tlp']['battery_charge_thresholds']
    )
    notifies :run, 'execute[reload tlp]', :delayed
  end
else
  file '/etc/tlp.d/01-woodenbits.conf' do
    action :delete
    notifies :run, 'execute[reload tlp]', :delayed
  end

  execute 'reload tlp' do
    command 'tlp start'
    action :nothing
    only_if 'which tlp'
  end
end
