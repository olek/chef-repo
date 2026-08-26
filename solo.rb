current_dir = File.expand_path(__dir__)

log_level          :info
log_location       "/var/log/chef/client.log"
file_cache_path    "/var/cache/chef"
file_backup_path   "/var/lib/chef/backup"
pid_file           "/var/run/chef/client.pid"
cache_options({ :path => "/var/cache/chef/checksums", :skip_expires => true })
chef_guid_path     "/var/cache/chef/chef_guid"


Mixlib::Log::Formatter.show_time = true
ohai.optional_plugins = [:Passwd]
# Disable cloud plugins to speed up boot.
# Also disable Filesystem: stale network/NFS mounts (like /mnt/nimbus2k/home)
# cause ~35-second hangs during Ohai filesystem collection, and no recipes use it.
ohai.disabled_plugins = [
  :Azure, :Cloud, :Cloudstack, :CloudV2, :DigitalOcean, :EC2,
  :Eucalyptus, :GCE, :Joyent, :Linode, :Openstack, :Rackspace, :Softlayer,
  :Filesystem
]
verbose_logging false

chefrepo_dir current_dir
node_path     "#{file_cache_path}/nodes"
role_path     "#{chefrepo_dir}/roles"
data_bag_path "#{chefrepo_dir}/data_bags"
cookbook_path ["#{chefrepo_dir}/cookbooks", "#{chefrepo_dir}/site-cookbooks"]

require 'socket'
hostname = Socket.gethostname
json_attribs "#{chefrepo_dir}/nodes/#{hostname}.json"
