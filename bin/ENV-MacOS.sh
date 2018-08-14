#!/bin/bash


download_path='/tmp/Downloads'
mkdir -p ${download_path}


function install_env(){

    # TODO :: 检查安装

    # 安装autoconf 【phalcon会用到】
    cd ${download_path}
    curl -O http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
    tar zxf autoconf-2.69.tar.gz
    cd autoconf-2.69
    ./configure
    make && make install

    # 安装pcre
    cd ${download_path}
    curl -O https://ftp.pcre.org/pub/pcre/pcre-8.41.tar.gz
    tar zxf pcre-8.41.tar.gz
    cd pcre-8.41
    ./configure
    make && make install

    # 安装openssl
    cd ${download_path}
    curl -O https://www.openssl.org/source/openssl-1.1.0g.tar.gz
    tar zxf openssl-1.1.0g.tar.gz
    cd openssl-1.1.0g
    ./config
    make && make install

    # 安装yaml
    cd ${download_path}
    curl -O http://pyyaml.org/download/libyaml/yaml-0.1.7.tar.gz
    tar zxf yaml-0.1.7.tar.gz
    cd yaml-0.1.7
    ./configure
    make && make install
}


# 安装nginx
function install_nginx(){
    exist=`ls /usr/local | grep nginx | wc -l`
    if [ $exist -gt 0 ]; then
        echo "nginx is already installed"
        return
    fi

    cd ${download_path}
    curl -O http://nginx.org/download/nginx-1.14.0.tar.gz
    tar zxf nginx-1.14.0.tar.gz
    cd nginx-1.14.0
    ./configure --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module
    make && make install
    ln -s /usr/local/nginx/sbin/nginx /usr/local/bin/nginx
    chown -R www:www /usr/local/nginx/logs
    chown -R www:www /usr/local/nginx/*temp
}


# 安装PHP
function install_php(){
    exist=`ls /usr/local | grep php | wc -l`
    if [ $exist -gt 0 ]; then
        echo "php is already installed"
        return
    fi

    cd ${download_path}
    curl -s https://php-osx.liip.ch/install.sh | bash -s 7.1
    ln -s /usr/local/php5/bin/php /usr/local/bin/php
    ln -s /usr/local/php5/bin/pecl /usr/local/bin/pecl
    ln -s /usr/local/php5/bin/php-config /usr/local/bin/php-config
    ln -s /usr/local/php5/bin/phpize /usr/local/bin/phpize
    ln -s /usr/local/php5/sbin/php-fpm /usr/local/bin/php-fpm


    # 安装Composer
    exist=`ls /usr/local/bin | grep composer | wc -l`
    if [ $exist -gt 0 ]; then
        echo "composer is already installed"
        return
    fi

    cd ${download_path}
    curl -sS https://getcomposer.org/installer | /usr/local/bin/php
    mv composer.phar /usr/local/bin/composer



    ###############################################################
    #                          拓展安装                            #
    ###############################################################
    # 更新拓展 MongoDB extension 1.4.4
    # 此处不建议使用pecl命令直接更新. pecl可能因为找不到openssl而失败
    # 找不到openssl会提示错误 mongodb-1.4.4/src/libmongoc/src/mongoc/mongoc-init.c:32:10: fatal error: 'tls.h' file not found
    # pecl uninstall mongodb && pecl install mongodb
    cd ${download_path}
    curl -O https://pecl.php.net/get/mongodb-1.4.4.tgz
    tar zxf mongodb-1.4.4.tgz
    cd mongodb-1.4.4
    phpize
    # 此处openssl位置根据实际情况调整
    ./configure --with-mongodb-ssl=/usr/local/include/openssl
    make && make install


    # 安装php拓展 yaml
    # TODO :: 此处有交互处理
    # cd ${download_path}
    # pecl install yaml
    # echo 'extension=yaml.so' > /usr/local/php5/php.d/50-extension-yaml.ini

    install_php_ext_grpc
    install_php_ext_phalcon
}



function install_php_ext_grpc(){
    # 安装GRPC
    # https://grpc.io/
    exist=`grep -r -n grpc.so /usr/local/php5/php.d/ | wc -l`
    if [ $exist -gt 0 ]; then
        echo "grpc is already installed"
        return
    fi
    pecl install grpc
    echo 'extension=grpc.so' > /usr/local/php5/php.d/50-extension-grpc.ini
}


# 安装phalcon
function install_php_ext_phalcon(){
    exist=`grep -r -n phalcon.so /usr/local/php5/php.d/ | wc -l`
    if [ $exist -gt 0 ]; then
        echo "phalcon is already installed"
        return
    fi

    cd ${download_path}
    git clone --depth=1 "git://github.com/phalcon/cphalcon.git"
    cd cphalcon/build
    sudo ./install
    echo 'extension=phalcon.so' > /usr/local/php5/php.d/50-extension-phalcon.ini
}


# 安装MySQL
function install_mysql(){
    exist=`ls /usr/local | grep mysql | wc -l`
    if [ $exist -gt 0 ]; then
        echo "mysql is already installed"
        return
    fi

    cd ${download_path}
    #curl -O https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.21-macos10.13-x86_64.tar.gz
    curl -O https://cdn.mysql.com/Downloads/MySQL-5.7/mysql-5.7.21-macos10.13-x86_64.tar.gz
    tar zxf mysql-5.7.21-macos10.13-x86_64.tar.gz
    mv mysql-5.7.21-macos10.13-x86_64 /usr/local/mysql
    mkdir -p /data/mysql
    ln -s /data/mysql /usr/local/mysql/data
    chown -R mysql:mysql /usr/local/mysql/data
    cd /usr/local/mysql/bin
    ./mysqld --initialize --user=mysql --basedir=/usr/local/mysql --explicit_defaults_for_timestamp
    ln -s /usr/local/mysql/bin/mysql /usr/local/bin/mysql
    ln -s /usr/local/mysql/bin/mysqld_safe /usr/local/bin/mysqld_safe
    # MySQL密码策略
    # ALTER USER USER() IDENTIFIED BY 'new_password'
}


# Redis
function install_redis(){
    exist=`ls /usr/local | grep redis | wc -l`
    if [ $exist -gt 0 ]; then
        echo "redis is already installed"
        return
    fi

    cd ${download_path}
    curl -O http://download.redis.io/releases/redis-4.0.8.tar.gz
    tar zxf redis-4.0.8.tar.gz
    cd redis-4.0.8
    make PREFIX=/usr/local/redis install
    cp redis.conf /usr/local/redis/
    ln -s /usr/local/redis/bin/redis-server /usr/local/bin/redis-server
    ln -s /usr/local/redis/bin/redis-cli /usr/local/bin/redis-cli
    # config
    sed -i '' "s/daemonize no/daemonize yes/g" /usr/local/redis/redis.conf
    sed -i '' "s/logfile \"\"/logfile \"\/data\/redis\/redis.log\"/g" /usr/local/redis/redis.conf
    sed -i '' "s/dir .\//dir \/data\/redis\//g" /usr/local/redis/redis.conf
    # 禁用危险指令 CONFIG, FLUSHALL, FLUSHDB
    # 产品环境不使用KEYS对性能影响很大
    sed -i '' "s/# rename-command CONFIG \"\"/rename-command CONFIG \"\"/g" /usr/local/redis/redis.conf
    # 配置-安全
    sed -i '' "/^rename-command CONFIG/a\\
    rename-command FLUSHALL \"\"\\
    " /usr/local/redis/redis.conf
    sed -i '' "/^rename-command CONFIG/a\\
    rename-command FLUSHDB f671c157a1a449f9c8d31e8594e25df2\\
    " /usr/local/redis/redis.conf
}


# MongoDB
function install_mongodb(){
    exist=`ls /usr/local | grep mongodb | wc -l`
    if [ $exist -gt 0 ]; then
        echo "mongodb is already installed"
        return
    fi

    cd ${download_path}
    curl -O https://fastdl.mongodb.org/osx/mongodb-osx-ssl-x86_64-3.6.3.tgz
    tar zxf mongodb-osx-ssl-x86_64-3.6.3.tgz
    mv mongodb-osx-ssl-x86_64-3.6.3 /usr/local/mongodb
    ln -s /usr/local/mongodb/bin/mongo /usr/local/bin/mongo
    ln -s /usr/local/mongodb/bin/mongod /usr/local/bin/mongod
    touch /usr/local/mongodb/mongod.conf.yml
}


function main(){
    install_env
    install_nginx
    install_php
    install_mysql
    install_redis
    install_mongodb
}


main