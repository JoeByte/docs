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
    # https://www.java.com/en/download/manual.jsp
    export JAVA_HOME=/usr/local/java
    export PATH=$PATH:$JAVA_HOME/bin
    # export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
    # source ~/.bashrc 
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
    mkdir -p /data/zookeeper/
    config='/usr/local/zookeeper/conf/zoo.cfg'
    cp /usr/local/zookeeper/conf/zoo_sample.cfg $config
    sed -i -e "s/dataDir=\/tmp\/zookeeper/dataDir=\/data\/zookeeper/g" $config
    echo 'server.1=zoo1:2888:3888' >> $config
    echo 'server.2=zoo2:2888:3888' >> $config
    echo 'server.3=zoo3:2888:3888' >> $config

    # TODO :: 手动标注集群ID
    # 每个节点不一样
    echo '1' >/data/zookeeper/myid

    # hosts
    ip=`get_ip`
    echo "${ip}\tzoo1" >> /etc/hosts
    echo "${ip}\tzoo2" >> /etc/hosts
    echo "${ip}\tzoo3" >> /etc/hosts

    # 启动
    # /usr/local/zookeeper/bin/zkServer.sh start
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
    # port = 9092
    # advertised.host.name = 172.0.0.2 
    return
}

# 安装flume
function install_flume(){
    exist=`ls /usr/local | grep flume | wc -l`
    if [ $exist -gt 0 ]; then
        echo "flume is already installed"
        return
    fi
    # curl -O http://mirrors.tuna.tsinghua.edu.cn/apache/flume/1.8.0/apache-flume-1.8.0-bin.tar.gz
    # tar xzf apache-flume-1.8.0-bin.tar.gz
    # mv apache-flume-1.8.0-bin /usr/local/flume
    return
}

function docs(){
    return
}

function main(){
    func='install_'$1
    $func
    return
}


count=$#
if [ $count != 2 ]; then
    echo 'args input error'
    exit
else
    if [ $1 != 'install' ]; then
        echo 'comman install <package>'
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












