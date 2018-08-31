1.	将zookeeper_isntall上传至包服务器/opt/ansible目录下；
2.	将zookeeper-3.4.8.tar.gz上传至/opt/ansibe/packet目录下；
3.	配置host.config配置文件，将作为zookeeper集群的机器填写在该配置文件中，每行填写一个ip；
注：zookeeper集群要求服务器数量>=3，并且为奇数个。
4.	cd /opt/ansible/zookeeper_isntall ，执行sh zookeeper_install.sh；
