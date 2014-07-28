use_inline_resources if defined?(use_inline_resources)

def whyrun_supported?
  true
end

action :create do

end

action :create_if_missing do
    bc = Bind9mgr::NamedConf.new ('/etc/bind/named.conf.local',
            :main_ns => '',
            :secondary_ns => '',
            :support_email = > '',
            :main_server_ip => ''
        )
end

action :touch do

end

action :delete do

end
