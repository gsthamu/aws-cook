include_recipe "java"

case node.platform
when "centos","redhat","fedora"
  include_recipe "jpackage"
end

tomcat_pkgs = value_for_platform(
  ["debian","ubuntu"] => {
    "default" => ["tomcat7","tomcat7-admin"]
  },
  ["centos","redhat","fedora"] => {
    "default" => ["tomcat7","tomcat7-admin-webapps"]
  },
  "default" => ["tomcat7"]
)
tomcat_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

service "tomcat" do
  service_name "tomcat7"
  case node["platform"]
  when "centos","redhat","fedora"
    supports :restart => true, :status => true
  when "debian","ubuntu"
    supports :restart => true, :reload => true, :status => true
  end
  action [:enable, :start]
end

case node["platform"]
when "centos","redhat","fedora"
  template "/etc/sysconfig/tomcat7" do
    source "sysconfig_tomcat7.erb"
    owner "gooruapp"
    group "gooruapp"
    mode "0644"
    notifies :restart, resources(:service => "tomcat")
  end
else  
  template "/etc/default/tomcat7" do
    source "default_tomcat7.erb"
    owner "gooruapp"
    group "gooruapp"
    mode "0644"
    notifies :restart, resources(:service => "tomcat")
  end
end

template "/home/gooruapp/tomcat7/server.xml" do
  source "server.xml.erb"
  owner "gooruapp"
  group "gooruapp"
  mode "0644"
  notifies :restart, resources(:service => "tomcat")
end
