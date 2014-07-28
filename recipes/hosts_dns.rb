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

log "hosts: #{hosts.join(', ')}" do
  level :debug
end


nameservers = search(:node, "role:nameserver")

log "nameservers: #{nameservers.join(', ')}" do
  level :debug
end


zones = search(:zones, "*:*")

log "zones: #{zones.join(', ')}" do
  level :debug
end


execute "reload-bind9" do
  command "service bind9 stop && service bind9 start"
  action :nothing
end


zones.each do |zone|

    puts zone

    template "/var/lib/bind/#{zone.base}" do
        source "example.tld"
        owner "root"
        group "bind"
        mode 0644
        variables(
            :zone => zone,
            :nameservers => nameservers,
            :hosts => hosts
        )
    end
end

template "/etc/bind/named.conf.local" do
    source "named.conf.local"
    owner "root"
    group "bind"
    mode 0644
    variables(
        :zones => zones
    )
    notifies :run, resources(:execute => "reload-bind9")
end
