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
verbose_logging false

chefrepo_dir current_dir
role_path     "#{chefrepo_dir}/roles"
data_bag_path "#{chefrepo_dir}/data_bags"
cookbook_path ["#{chefrepo_dir}/cookbooks", "#{chefrepo_dir}/site-cookbooks"]

require 'socket'
hostname = Socket.gethostname
json_attribs "#{chefrepo_dir}/nodes/#{hostname}.json"
