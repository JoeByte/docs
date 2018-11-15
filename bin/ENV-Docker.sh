#!/bin/sh


# 创建docker容器
# docker run -it --name AppName -v /Users:/root/shared centos bash


# 安装环境
function env(){
    
    yum install -y vim net-tools
    
    # nginx需要
    yum install -y gcc pcre-devel openssl-devel
    

    return
}

# 获取IP地址
function get_ip(){
    # 多IP地址仅取一个
    ip=`ifconfig | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk 'NR==1{print $2}' | tr -d "addr:"`
    echo $ip
}

# 安装java
function install_java(){
    exist=`ls /usr/local/ | grep java | wc -l`
    if [ $exist -gt 0 ]; then
        echo "java is already installed"
        return
    fi


    # TODO :: 手动下载java
    # https://www.java.com/en/download/manual.jsp

    # 环境变量
    env=`cat ~/.bashrc | grep JAVA_HOME | wc -l`
    if [ $env -gt 0 ]; then
        echo "java environment is already installed"
        return
    fi
    echo 'export JAVA_HOME=/usr/local/java' >> ~/.bashrc
    echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~/.bashrc
    source ~/.bashrc 
    return
}

# 安装zookeeper
function install_zookeeper(){
    exist=`ls /usr/local | grep zookeeper | wc -l`
    if [ $exist -gt 0 ]; then
        echo "zookeeper is already installed"
        return
    fi

    # 安装
    curl -O http://mirror.bit.edu.cn/apache/zookeeper/stable/zookeeper-3.4.10.tar.gz
    tar xzf zookeeper-3.4.10.tar.gz
    mv zookeeper-3.4.10 /usr/local/zookeeper

    # 配置
    mkdir -p /usr/local/zookeeper/data/
    config='/usr/local/zookeeper/conf/zoo.cfg'
    cp /usr/local/zookeeper/conf/zoo_sample.cfg $config
    sed -i -e "s/dataDir=\/tmp\/zookeeper/dataDir=\/data\/zookeeper/g" $config
    echo 'server.1=zoo1:2888:3888' >> $config
    echo 'server.2=zoo2:2888:3888' >> $config
    echo 'server.3=zoo3:2888:3888' >> $config

    # TODO :: 手动标注集群ID
    # 每个节点不一样
    echo '1' >/usr/local/zookeeper/data/myid

    # hosts
    ip=`get_ip`
    echo "${ip}\tzoo1" >> /etc/hosts
    echo "${ip}\tzoo2" >> /etc/hosts
    echo "${ip}\tzoo3" >> /etc/hosts

    # 启动
    # /usr/local/zookeeper/bin/zkServer.sh start
    #
    # 关闭
    # /usr/local/zookeeper/bin/zkServer.sh stop
    #
    # 连接
    # /usr/local/zookeeper/bin/zkCli.sh -server 127.0.0.1:2181
    return
}

# 安装kafka
function install_kafka(){
    exist=`ls /usr/local | grep kafka | wc -l`
    if [ $exist -gt 0 ]; then
        echo "kafka is already installed"
        return
    fi

    echo "start install kafka ..."
    cd ${download_path}
    curl -O http://mirrors.tuna.tsinghua.edu.cn/apache/kafka/1.0.1/kafka_2.11-1.0.1.tgz
    tar xzf kafka_2.11-1.0.1.tgz
    mv kafka_2.11-1.0.1 /usr/local/kafka

    # 配置
    ip=`get_ip`
    config='/usr/local/kafka/config/server.properties'
    sed -i "s/zookeeper.connect=localhost:2181/zookeeper.connect=zoo1:2181,zoo2:2181,zoo3:2181\/kafka/g" $config
    sed -i "s/log.dirs=\/tmp\/kafka-logs/log.dirs=\/data\/kafka-logs/g" $config
    sed -i '/broker.id=/a\delete.topic.enable=true' $config
    sed -i "/broker.id=/a\listeners=PLAINTEXT:\/\/${ip}:9092" $config
    # 新版本中 advertised.listeners或者listeners 取代 advertised.host.name 和 port
    # sed -i "/broker.id=/a\port=9092" $config
    # sed -i "/broker.id=/a\advertised.host.name=${ip}" $config

    # TODO :: 手动标注broker.id=1

    # 启动
    # nohup /usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties &
    #
    # 关闭
    # /usr/local/kafka/bin/kafka-server-stop.sh
    return
}

# 安装flume
function install_flume(){
    exist=`ls /usr/local | grep flume | wc -l`
    if [ $exist -gt 0 ]; then
        echo "flume is already installed"
        return
    fi
    
    echo "start install flume ..."
    cd ${download_path}
    curl -O http://mirrors.tuna.tsinghua.edu.cn/apache/flume/1.8.0/apache-flume-1.8.0-bin.tar.gz
    tar xzf apache-flume-1.8.0-bin.tar.gz
    mv apache-flume-1.8.0-bin /usr/local/flume

    # 配置
    cat > /usr/local/flume/conf/kafka-conf.properties << EOF
a1.sources = r1
a1.channels = c1
a1.sinks = k1
a1.sources.r1.channels = c1
a1.sources.r1.type = exec
a1.sources.r1.command = tail -F /data/logs/nginx/access.log
a1.channels.c1.type = org.apache.flume.channel.kafka.KafkaChannel
a1.channels.c1.kafka.bootstrap.servers = kafka1:9092,kafka2:9092,kafka3:9092
a1.channels.c1.kafka.topic = nginx
a1.channels.c1.kafka.consumer.group.id = flume-consumer
EOF

    # TODO :: 加入kafka服务器IP到hosts文件

    # 启动
    # cd /usr/local/flume
    # bin/flume-ng agent --conf conf --conf-file conf/kafka-conf.properties --name a1 -Dflume.root.logger=INFO,console

    return
}

# 安装hbase
function install_hbase(){
    exist=`ls /usr/local | grep hbase | wc -l`
    if [ $exist -gt 0 ]; then
        echo "hbase is already installed"
        return
    fi
    
    curl -O http://mirrors.shu.edu.cn/apache/hbase/2.0.0/hbase-2.0.0-bin.tar.gz
    tar xzf hbase-2.0.0-bin.tar.gz
    mv hbase-2.0.0 /usr/local/hbase

    # 使用现有已存在的zookeeper
    sed -i "s/# export HBASE_MANAGES_ZK=true/export HBASE_MANAGES_ZK=false/g" /usr/local/hbase/conf/hbase-env.sh

    # 启动
    # bin/start-hbase.sh

    # 关闭
    # bin/stop-hbase.sh


    # 参考配置 hbase-site.xml
    # hbase.rootdir 可配置为HDFS  hdfs://
    # 
    # <configuration>
    #   <property>
    #     <name>hbase.rootdir</name>
    #     <value>file:///tmp/hbase</value>
    #   </property>
    #   <property>
    #     <name>hbase.cluster.distributed</name>
    #     <value>true</value>
    #   </property>
    #   <property>
    #     <name>hbase.zookeeper.quorum</name>
    #     <value>zoo1,zoo2,zoo3</value>
    #   </property>
    # </configuration>
}

# 文档
function docs(){
        cat << EOF
========================================================================
NAME
    distools - Distributed environment installation tools.

SYNOPSIS
    distools.sh install <package>

DESCRIPTION
    this project is used to install zookeeper flume kafka spark hadoop

    The options are as follows:

    -i <package>        install a package, the alias of install

    install <package>   install a package

EXAMPLES
    The following is how to install zookeeper

        distools.sh install zookeeper
========================================================================

EOF
    return
}

# 入口
function main(){
    func='install_'$1
    $func
    return
}

count=$#
if [ $count != 2 ]; then
    docs
    exit
else
    if [ $1 != 'install' ]; then
        docs
        exit
    fi
fi

# 安装目录
download_path='/tmp/Downloads'
mkdir -p ${download_path}

main $2


# for args in $@
# do
#     echo $args
# done












