# Cookbook:: zookeeper
# Recipe:: default
# Copyright:: 2024, redborder
# License:: Affero General Public License, Version 3

zookeeper_config 'Zookeeper config' do 
  logdir node['zookeeper']['logdir']
  action :add
end
