#
# Cookbook Name:: autodnshosts
#
# No Copyright.
#
# Based on http://powdahound.com/2010/07/dynamic-hosts-file-using-chef
# Use at your own risk.
#

# Find all nodes, sorting by Chef ID so their
# order doesn't change between runs.
#hosts = search(:node, "*:*", "X_CHEF_id_CHEF_X asc")
hosts = search(:node, "*:*")

log "Hosts: #{hosts.join(', ')}" do
  level :debug
end

zones = search(:zones, "*:*")

log "Zones: #{zones.join(', ')}" do
  level :debug
end

execute "reload-bind9" do
  command "killall -HUP bind9 || true"
  action :nothing
end

zones.each do |z|

    puts z

    template "/etc/bind/zones.#{z.id}" do
        source "zonefile"
        owner "root"
        group "root"
        mode 0644
        variables(
            :zone => z,
            :hosts => hosts
        )
        notifies :run, resources(:execute => "reload-bind9")
    end
end

