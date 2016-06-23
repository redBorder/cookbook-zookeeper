# Cookbook Name:: zookeeper
#
# Provider:: zk2_config
#

action :add do
  begin
    memory = new_resource.memory
    logdir = new_resource.logdir
    user = new_resource.user
    group = new_resource.group
    zk_hosts = new_resource.zk_hosts
    managers = new_resource.managers
    datadir = new_resource.datadir
    port = new_resource.port
 
    user user do
      action :create
      system true
    end

    service "zookeeper2" do
      service_name "zookeeper2"
      ignore_failure true
      supports :status => true, :reload => true, :restart => true, :enable => true
    end

    directory logdir do
      owner user
      group group
      mode 0770
      action :create
    end

    directory "/etc/zookeeper2" do
      owner user
      group group
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

    template "/etc/zookeeper2/zoo.cfg" do
        source "zoo.cfg.erb"
        owner "root"
        group "root"
        mode 0644
        retries 2
#        notifies :restart, "service[zookeeper2]", :delayed if (manager_services["zookeeper2"] and (!zookeeper2_virtual or zookeeper2_running))
        variables(:managers => managers, :zk_hosts => zk_hosts, :data_dir => datadir, :port => port )
    end

    template "/etc/zookeeper2/log4j.properties" do
        source "zookeeper2_log4j.properties.erb"
        owner "root"
        group "root"
        mode 0644
#        notifies :restart, "service[zookeeper2]", :delayed if (manager_services["zookeeper2"] and (!zookeeper2_virtual or zookeeper2_running))
    end
    template "/etc/sysconfig/zookeeper2" do
      source "zookeeper2_sysconfig.erb"
      owner "root"
      group "root"
      mode 0644
      retries 2
      #variables(:memory => memory_services[x])
      #notifies :restart, "service[#{x}]", :delayed if manager_services[x]
    end

    template "#{datadir}/myid" do
        source "zookeeper2_myid.erb"
        owner user
        group group
        mode 0644
        #variables(:manager_index => manager_index, :zookeeper2_virtual => zookeeper2_virtual )
        #notifies :restart, "service[zookeeper2]", :delayed if (manager_services["zookeeper2"] and (!zookeeper2_virtual or zookeeper2_running))
        #notifies :run, "execute[force_chef_client_wakeup]", :delayed
    end

    template "/etc/zookeeper2.list" do
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

    Chef::Log.info("Zookeeper2 has been configured correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end

