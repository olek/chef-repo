# Cookbook Name:: woodenbits
# Recipe:: truecrypt
#
# TODO: TrueCrypt 7.1a is abandonware (development ended in 2014). Migrate to
# VeraCrypt, its maintained successor: install the veracrypt package, switch the
# bashrc tc-* helper functions and the shutdown dismount below to the veracrypt
# CLI, and drop the bundled truecrypt_7.1a tarball.

#truecrypt_archive = 'truecrypt_7.1a_console_i386.tar.gz'
truecrypt_archive = 'truecrypt_7.1a_amd64.tar.gz'
cookbook_file "/root/install/#{truecrypt_archive}" do
  source "system/root-install/#{truecrypt_archive}"
  mode 0640
end

bash 'install truecrypt' do
  cwd '/'
  code <<-EOH
    tar xfz /root/install/#{truecrypt_archive}
  EOH
  creates '/usr/bin/truecrypt'
end

# Tear down the obsolete SysV hook if a previously-provisioned machine still has
# it, so we never run both the init.d script and the systemd unit below.
execute 'deregister old truecrypt init.d hook' do
  command 'update-rc.d -f truecrypt-dismount remove'
  only_if { ::File.exist?('/etc/init.d/truecrypt-dismount') }
end

file '/etc/init.d/truecrypt-dismount' do
  action :delete
end

# Force-dismount any mounted truecrypt volumes on shutdown/reboot so they are
# not left dirty. A oneshot service that does its work in ExecStop replaces the
# obsolete SysV /etc/init.d + update-rc.d hook.
file '/etc/systemd/system/truecrypt-dismount.service' do
  content <<~EOF
    [Unit]
    Description=Dismount all truecrypt volumes on shutdown
    DefaultDependencies=no
    Before=shutdown.target umount.target
    Conflicts=shutdown.target

    [Service]
    Type=oneshot
    RemainAfterExit=yes
    ExecStart=/bin/true
    ExecStop=/bin/bash -c 'for volume in $(grep "/dev/mapper/truecrypt" /proc/mounts | awk "{print \\$2}"); do truecrypt --text --verbose --non-interactive --force --dismount "$volume"; done'

    [Install]
    WantedBy=multi-user.target
  EOF
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[truecrypt-systemctl-daemon-reload]', :immediately
end

execute 'truecrypt-systemctl-daemon-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

# Enable so ExecStop fires at shutdown. RemainAfterExit keeps it "active" after
# the no-op ExecStart, which is what makes systemd run ExecStop on the way down.
service 'truecrypt-dismount' do
  action [:enable, :start]
end
