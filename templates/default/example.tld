; zone configuration file
$TTL 3D
@       IN      SOA     <%= @zone[:id] %>. <%= @zone[:root] %>. (
                        2014062301      ; serial, todays date + todays serial #
                        60              ; refresh, seconds
                        60              ; retry, seconds
                        60              ; expire, seconds
                        60 )            ; minimum, seconds

;
; Nameserver Records
;
<% @nameservers.each_with_index do |nameserver, i| %>
@       IN      NS      <%= @nameservers[i]["fqdn"] %>.
<% end %>
;
; Applications DNS
;
; these are the CNAME records from self registering applications.


;
; Nodes
; these are the IP addresses, FQDNs and short host names for all other machines
; this machine is going to be repeated here, but it does not matter since it is
; the first match that counts
<% @hosts.each_with_index do |node, i| %>
<% if ((@hosts[i]["hostname"] != nil) && (@hosts[i]["ipaddress"] != nil)) %>
<%= @hosts[i]["hostname"] %>        A       <%= @hosts[i]["ipaddress"] %>
<% end %>
<% end %>
