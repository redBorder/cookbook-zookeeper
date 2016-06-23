# Cookbook Name:: zookeeper
#
# Provider:: zk_config
#

action :add do
  begin
    memory = new_resource.memory
    logdir = new_resource.logdir
    datadir = new_resource.datadir
    user = new_resource.user
    group = new_resource.group
    port = new_resource.port
    zk_hosts = new_resource.zk_hosts
    managers = new_resource.managers

    user user do
      action :create
      system true
    end

    service "zookeeper" do
      service_name "zookeeper"
      ignore_failure true
      supports :status => true, :reload => true, :restart => true, :enable => true
    end

    directory logdir do
      owner user
      group group
      mode 0770
      action :create
    end
    
    directory "/etc/zookeeper" do
      owner "zookeeper"
      group "zookeeper"
      mode 0770
      action :create
    end

    directory datadir do
      owner "zookeeper"
      group "zookeeper"
      mode 0700
      recursive true
      action :create
    end

    template "/etc/zookeeper/zoo.cfg" do
        source "zoo.cfg.erb"
        owner "root"
        group "root"
        mode 0644
        retries 2
#        notifies :restart, "service[zookeeper]", :delayed if manager_services["zookeeper"]
        variables(:managers => managers, :zk_hosts => zk_hosts, :data_dir => datadir, :port => port )
    end

    template "/etc/zookeeper/log4j.properties" do
        source "zookeeper_log4j.properties.erb"
        owner "root"
        group "root"
        mode 0644
        retries 2
       # notifies :restart, "service[zookeeper]", :delayed if manager_services["zookeeper"]
    end

    template "/etc/sysconfig/zookeeper" do
      source "zookeeper_sysconfig.erb"
      owner "root"
      group "root"
      mode 0644
      retries 2
   #   variables(:memory => memory_services[x])
    #  notifies :restart, "service[#{x}]", :delayed if manager_services[x]
    end

    template "#{datadir}/myid" do
        source "zookeeper_myid.erb"
        owner user
        group group
        mode 0644
        #variables(:manager_index => manager_index )
        #notifies :restart, "service[zookeeper]", :delayed if manager_services["zookeeper"]
        #notifies :run, "execute[force_chef_client_wakeup]", :delayed
    end

    template "/etc/zookeeper.list" do
      source "managers.list.erb"
      owner "root"
      group "root"
      mode 0644
      retries 2
      #variables(:managers => managers_per_service["zookeeper"])
      #notifies :restart, "service[rb-sociald]", :delayed if manager_services["rb-sociald"]
      #notifies :restart, "service[nmspd]", :delayed if manager_services["nmspd"]
      #notifies :restart, "service[nprobe]", :delayed if manager_services["nprobe"]
    end

    Chef::Log.info("Zookeeper has been configured correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end

