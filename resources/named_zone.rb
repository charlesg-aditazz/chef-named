actions :create, :create_if_missing, :touch, :delete

state_attrs :zone_id,
            :zone_root,
            :zone_serial,
            :nameservers,
            :hosts,
            :applications

attribute :zone_id, :kind_of => String, :name_attribute => true
attribute :zone_root, :kind_of => String
attribute :zone_serial, :kind_of => Integer, :default =>  # serial, todays date + todays serial
attribute :nameservers, :kind_of => Array, :default => []
attribute :hosts, :kind_of => Array, :default => []
attribute :applications, :kind_of => Array, :default => []
