# Cookbook Name:: Zookeeper
#
# Resource:: config
#

actions :add, :remove
default_action :add

attribute :memory, :kind_of => String, :default => "512"
attribute :logdir, :kind_of => String, :default => "/var/log/zookeeper"
attribute :user, :kind_of => String, :default => "zookeeper"
attribute :group, :kind_of => String, :default => "zookeeper"
attribute :datadir, :kind_of => String, :default => "/tmp/zookeeper"
attribute :zk_hosts, :kind_of => Array, :default => ["localhost"]
attribute :managers, :kind_of => Array, :default => ["localhost"]
attribute :port, :kind_of => Fixnum, :default => 2181
