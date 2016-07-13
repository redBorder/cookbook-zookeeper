# Cookbook Name:: zookeeper
#
# Provider:: config
#

action :add do
  begin
    cbk_name = new_resource.cbk_name
    memory = new_resource.memory
    logdir = new_resource.logdir
    datadir = new_resource.datadir
    user = new_resource.user
    group = new_resource.group
    port = new_resource.port
    zk_hosts = new_resource.zk_hosts
    managers = new_resource.managers
    memory = new_resource.memory
    classpath = new_resource.classpath
    log4j = new_resource.log4j
    jvmflags = new_resource.jvmflags
    zoomain = new_resource.zoomain
    zoocfg = new_resource.zoocfg

    package "zookeeper" do
      action :install
    end

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
        cookbook cbk_name
        notifies :restart, "service[zookeeper]"
        variables(:managers => managers, :zk_hosts => zk_hosts, :data_dir => datadir, :port => port )
    end

    template "/etc/zookeeper/log4j.properties" do
        source "zookeeper_log4j.properties.erb"
        owner "root"
        group "root"
        mode 0644
        cookbook cbk_name
        notifies :restart, "service[zookeeper]"
    end

    template "/etc/sysconfig/zookeeper" do
      source "zookeeper_sysconfig.erb"
      owner "root"
      group "root"
      mode 0644
      cookbook cbk_name
      variables(:memory => memory, :classpath => classpath, :zoomain => zoomain, :log4j => log4j, :jvmflags => jvmflags, :zoocfg => zoocfg)
      notifies :restart, "service[zookeeper]"
    end

    #getting zk index
    if managers.include?(node.name)
      zk_index = managers.index(node.name) + 1
    else
      zk_index = 254
    end

    template "#{datadir}/myid" do
        source "zookeeper_myid.erb"
        owner user
        group group
        mode 0644
        cookbook cbk_name
        variables(:zk_index => zk_index )
        notifies :restart, "service[zookeeper]"
        #notifies :run, "execute[force_chef_client_wakeup]", :delayed
    end

    template "/etc/zookeeper.list" do
      source "managers.list.erb"
      owner "root"
      group "root"
      mode 0644
      cookbook cbk_name
      variables(:managers => managers)
      #notifies :restart, "service[rb-sociald]", :delayed if manager_services["rb-sociald"]
      #notifies :restart, "service[nmspd]", :delayed if manager_services["nmspd"]
      #notifies :restart, "service[nprobe]", :delayed if manager_services["nprobe"]
    end

    Chef::Log.info("Zookeeper has been configured correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end


action :remove do
  begin
    logdir = new_resource.logdir
    datadir = new_resource.datadir
    user = new_resource.user
    group = new_resource.group

    service "zookeeper" do
      service_name "zookeeper"
      supports :status => true, :stop => true
      action :stop
    end

    dir_list = [
      datadir,
      logdir,
      "/etc/zookeeper"
    ] 

    file_list = [
      "/etc/zookeeper/zoo.cfg",
      "/etc/zookeeper/log4j.properties",
      "/etc/sysconfig/zookeeper",
      "#{datadir}/myid",
      "/etc/zookeeper.list"
    ]

    dir_list.each do |dir|
      directory dir do
        recursive true
        action :delete
      end
    end

    file_list.each do |file__tmp|
      file file_tmp do
        action :delete
      end
    end

    Chef::Log.info("Zookeeper has been removed correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end
