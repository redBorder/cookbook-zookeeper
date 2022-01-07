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
    hosts = new_resource.hosts
    memory = new_resource.memory
    classpath = new_resource.classpath
    log4j = new_resource.log4j
    jvmflags = new_resource.jvmflags
    zoomain = new_resource.zoomain
    zoocfg = new_resource.zoocfg

    yum_package "zookeeper" do
      action :upgrade
      flush_cache [:before]
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
        variables(:hosts => hosts, :data_dir => datadir, :port => port )
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
    if hosts.include?(node.name)
      zk_index = hosts.index(node.name) + 1
    else
      zk_index = 254
    end

    template "#{datadir}/myid" do
        source "zookeeper_myid.erb"
        owner user
        group group
        mode 0644
        cookbook cbk_name
        retries 2
        variables(:zk_index => zk_index )
        notifies :restart, "service[zookeeper]"
        #notifies :run, "execute[force_chef_client_wakeup]", :delayed
    end

    template "/etc/zookeeper.list" do
      source "hosts.list.erb"
      owner "root"
      group "root"
      mode 0644
      cookbook cbk_name
      variables(:hosts => hosts)
      #notifies :restart, "service[rb-sociald]", :delayed if manager_services["rb-sociald"]
      #notifies :restart, "service[nmspd]", :delayed if manager_services["nmspd"]
      #notifies :restart, "service[nprobe]", :delayed if manager_services["nprobe"]
    end
    Chef::Log.info("Zookeeper cookbook has been processed")
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

    #dir_list.each do |dir|
    #  directory dir do
    #    recursive true
    #    action :delete
    #  end
    #end

    #file_list.each do |file_tmp|
    #  file file_tmp do
    #    action :delete
    #  end
    #end

    ## removing package
    #yum_package 'zookeeper' do
    #  action :remove
    #end

    Chef::Log.info("Zookeeper cookbook has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do
  begin
    if !node["zookeeper"]["registered"]
      query = {}
        query["ID"] = "zookeeper-#{node["hostname"]}"
        query["Name"] = "zookeeper"
        query["Address"] = "#{node["ipaddress"]}"
        query["Port"] = 2181
        json_query = Chef::JSONCompat.to_json(query)

        execute 'Register service in consul' do
            command "curl -X PUT http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
            action :nothing
        end.run_action(:run)

        node.set["zookeeper"]["registered"] = true
    end

    Chef::Log.info("Zookeeper service has been registered to consul")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    if node["zookeeper"]["registered"]
      execute 'Deregister service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/deregister/zookeeper-#{node["hostname"]} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.set["zookeeper"]["registered"] = false
    end
  rescue => e
    Chef::Log.info("Zookeeper has been deregistered to consul")
  end
end
