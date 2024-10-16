# Cookbook:: Zookeeper
# Resource:: config

actions :add, :remove, :register, :deregister
default_action :add

attribute :cbk_name, kind_of: String, default: 'zookeeper'
attribute :logdir, kind_of: String, default: '/var/log/zookeeper'
attribute :user, kind_of: String, default: 'zookeeper'
attribute :group, kind_of: String, default: 'zookeeper'
attribute :datadir, kind_of: String, default: '/tmp/zookeeper'
attribute :hosts, kind_of: Array, default: [node.name]
attribute :port, kind_of: Integer, default: 2181
attribute :memory, kind_of: Integer, default: 524288
attribute :classpath, kind_of: String, default: ''
attribute :log4j, kind_of: String, default: '-Dlog4j.configuration=file:///etc/zookeeper/log4j.properties'
attribute :jvmflags, kind_of: String, default: ''
attribute :zoomain, kind_of: String, default: '-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.local.only=false org.apache.zookeeper.server.quorum.QuorumPeerMain'
attribute :zoocfg, kind_of: String, default: '/etc/zookeeper/zoo.cfg'
attribute :ipaddress, kind_of: String, default: '127.0.0.1'
