default['zookeeper']['logdir'] = '/var/log/zookeeper'
default['zookeeper']['user'] = 'zookeeper'
default['zookeeper']['group'] = 'zookeeper'
default['zookeeper']['datadir'] = '/tmp/zookeeper'
default['zookeeper']['zk_hosts'] = [ node.name ]
default['zookeeper']['managers'] = [ node.name ]
default['zookeeper']['port'] = 2181
default['zookeeper']['memory'] = '524288'
default['zookeeper']['classpath'] = ''
default['zookeeper']['log4j'] = '-Dlog4j.configuration=file:///etc/zookeeper/log4j.properties'
default['zookeeper']['jvmflags'] = ''
default['zookeeper']['zoomain'] = '-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.local.only=false org.apache.zookeeper.server.quorum.QuorumPeerMain'
default['zookeeper']['zoocfg'] = '/etc/zookeeper/zoo.cfg'

default['zookeeper']['registered'] = false
