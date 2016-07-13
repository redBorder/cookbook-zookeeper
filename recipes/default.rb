#
# Cookbook Name:: zookeeper
# Recipe:: default
#
# Redborder, 2016
#
# AFFERO GENERAL PUBLIC LICENSE V3
#

zookeeper_config "Zookeeper config"do 
  logdir node["zookeeper"]["logdir"] 
  action :add
end

