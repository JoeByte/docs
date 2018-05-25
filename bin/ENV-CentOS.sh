#!/bin/sh
# name      环境安装脚本
# Package   Nginx Mysql PHP Phalcon phpMyAdmin Redis python拓展
# Author    joe@xxtime.com
# Link      http://www.xxtime.com


# 环境
export PATH=$PATH:/usr/local/bin
#source ~/.bash_profile


# 依赖关系
sleep 1
echo "....开始安装依赖...."
sleep 2

#rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/i386/Packages/e/epel-release-6-8.noarch.rpm
rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm
#rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

yum -y install lrzsz wget vim cmake autoconf git unzip mcrypt libaio pcre-devel p7zip re2c gpm gcc gcc-c++ libtool-ltdl libtool-ltdl-devel openssl openssl-devel curl curl-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libc-client libc-client-devel gd gd-devel libmcrypt libmcrypt-devel libicu libicu-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel libyaml-devel libxml2 libxml2-devel bison bison-devel libevent libenent-devel ncurses ncurses-devel krb5 krb5-devel gmp gmp-devel
# libaio mysql5.7
yum -y install net-tools iproute

# Centos7
#yum install net-tools iproute

sleep 1
echo "....依赖安装完成...."
sleep 1
echo "........................................"
sleep 1
echo "....开始安装nginx...."
sleep 2

# 安装nginx
mkdir -p /data/www
useradd -s /sbin/nologin -d /data/www www
mkdir -p /data/logs/nginx
chown -R www:www /data/logs/nginx/
wget http://nginx.org/download/nginx-1.12.2.tar.gz
tar zxf nginx-1.12.2.tar.gz
cd nginx-1.12.2
./configure --with-http_stub_status_module --with-http_ssl_module
# --with-http_stub_status_module 监控模块
make
make install
# 软链
ln -s /usr/local/nginx/sbin/nginx /usr/local/bin/nginx

# 配置
mkdir /usr/local/nginx/conf/conf.d
sed -i -e "s/user  nobody/user  www/g" /usr/local/nginx/conf/nginx.conf
# 权限
chown -R www:www /usr/local/nginx/logs
chown -R www:www /usr/local/nginx/*temp

sleep 1
cd ..
echo "....nginx安装完成...."
sleep 1
echo "........................................"
sleep 1
echo "....开始安装mysql...."
sleep 2


# 安装MySQL 文档5231行 2.9 Installing MySQL from Source
# 需要 yum -y install libaio
# 苹果系统 wget http://cdn.mysql.com/Downloads/MySQL-5.7/mysql-5.7.20-osx10.11-x86_64.tar.gz
# 搜狐镜像 http://mirrors.sohu.com/mysql/MySQL-5.7/
useradd -s /sbin/nologin mysql
wget https://cdn.mysql.com/Downloads/MySQL-5.7/mysql-5.7.21-linux-glibc2.12-x86_64.tar.gz
tar zxf mysql-5.7.20-linux-glibc2.5-x86_64.tar.gz
mv mysql-5.7.20-linux-glibc2.5-x86_64 /usr/local/mysql
cd /usr/local/mysql/
mkdir mysql-files
chmod 770 mysql-files
chown -R mysql .
chgrp -R mysql .
# 自定义
mkdir -p /data/mysql
chown -R mysql:mysql /data/mysql

# mysql客户端启动不了 可以通过设置my.cnf解决
# ln -s /var/lib/mysql/mysql.sock /tmp/mysql.sock
# mkdir -p /var/run/mysqld/
# chown mysql -R /var/run/mysqld/

# ./bin/mysqld_safe --user=mysql &
# 软链
#ln -s /usr/local/mysql/bin/mysqld /usr/local/bin/mysqld
ln -s /usr/local/mysql/bin/mysqld_safe /usr/local/bin/mysqld_safe
ln -s /usr/local/mysql/bin/mysql /usr/local/bin/mysql
ln -s /usr/local/mysql/bin/mysql_config /usr/local/bin/mysql_config
ln -s /usr/local/mysql/bin/mysqldump /usr/local/bin/mysqldump
ln -s /usr/local/mysql/bin/mysqladmin /usr/local/bin/mysqladmin

# Link http://dev.mysql.com/doc/refman/5.7/en/server-options.html
mkdir -p /data/logs/mysql
touch /data/logs/mysql/mysql.log
cp support-files/my-default.cnf /etc/my.cnf

# [mysqld] 在此配置下添加
# datadir=/data/mysql
sed -i -e "s/^datadir\(.*\)/datadir=\/data\/mysql/g" /etc/my.cnf
# log-error=/data/logs/mysql/mysql.log
sed -i -e "s/^log-error\(.*\)/log-error=\/data\/logs\/mysql\/mysql.log/g" /etc/my.cnf
# pid-file=/data/logs/mysql/mysql.pid
sed -i -e "s/^pid-file\(.*\)/pid-file=\/data\/logs\/mysql\/mysql.pid/g" /etc/my.cnf

# my.cnf 文件 [mysqld_safe] 与 [client] 标签下
# socket=/tmp/mysql.sock
# 此处如非/tmp/mysql.sock位置,则php会出问题
sed -i -e "s/^socket\(.*\)/socket=\/tmp\/mysql.sock/g" /etc/my.cnf

# [client] 在此配置下添加 TODO
# socket=/data/logs/mysql/mysql.sock
# is_mysql_client_exist=`cat /etc/my.cnf| grep '\[client\]'`


# &aw1wih3Hl<o

# 初始化参考资料 https://dev.mysql.com/doc/refman/5.7/en/data-directory-initialization-mysqld.html
# 此步骤生成授权密码 A temporary password is generated for root@localhost
# 此处不指定 --datadir=/data/mysql 避免出现未知问题, 后续可软连到此目录
./bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --explicit_defaults_for_timestamp
echo "........................................................................"
echo ".... 此步骤生成授权密码 ..................................................."
echo ".... SET PASSWORD = PASSWORD('your new password'); ....................."
echo ".... ALTER USER root@localhost PASSWORD EXPIRE NEVER; .................."
echo ".... FLUSH PRIVILEGES; ................................................."

echo ".... 请记录 root@localhost 的密码 ........................................"
echo ".... 使用./bin/mysqladmin -u root -p password 'new-password'修改密码 ........"
echo "........................................................................."
sleep 10
./bin/mysql_ssl_rsa_setup
chown -R root .
chown -R mysql /data/mysql /data/logs/mysql mysql-files

# 加入启动项
#cp support-files/mysql.server /etc/init.d/mysql.server

# 修改默认密码(连接数据库后操作)
# ALTER USER USER() IDENTIFIED BY 'new_password'

sleep 1
cd ..
echo "....mysql安装完成...."
sleep 1
echo "........................................"
sleep 10
echo "....开始安装PHP...."
sleep 2


# 解决php安装mysql拓展时找不到相关库问题
#ln -s /usr/local/mysql/lib/libmysqlclient.so.18 /usr/lib64/libmysqlclient.so.18
ln -s /usr/local/mysql/lib/libmysqlclient.so.20 /usr/lib64/libmysqlclient.so.20


# 安装PHP
cd /root/
#wget http://cn2.php.net/distributions/php-7.1.8.tar.gz
wget http://cn2.php.net/distributions/php-5.6.32.tar.gz
tar zxf php-5.6.32.tar.gz
cd php-5.6.32

# 备注: Mcrypt在PHP7.1.0中被弃用， 在PHP7.2.0中删除. 替代OpenSSL, Sodium (available as of PHP 7.2.0)
# 没有 ssh2 redis mongo
# cp ./ext/phar/phar.php  ./ext/phar/phar.phar
#./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-config-file-scan-dir=/usr/local/php/etc/php.d --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql --with-gettext --with-iconv --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-fpm --enable-mbstring --with-gd --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --with-openssl --enable-soap --enable-zip --enable-opcache=no
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-config-file-scan-dir=/usr/local/php/etc/php.d \
--with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
--with-curl --with-xmlrpc --with-openssl --with-gettext --with-iconv --with-mhash --with-freetype-dir \
--with-jpeg-dir --with-png-dir --with-gd \
--with-zlib --with-libxml-dir=/usr \
--enable-fpm --enable-exif --enable-xml --disable-rpath --enable-bcmath \
--enable-shmop --enable-sysvsem --enable-sysvshm --enable-sysvmsg \
--enable-inline-optimization --enable-mbregex --enable-mbstring --enable-pcntl \
--enable-sockets  --enable-soap \
--enable-zip --enable-opcache \
--enable-intl
#--with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql

# --with-libzip
# php5.5 可忽略此参数

# 新增 --enable-sysvshm --enable-sysvmsg

# --with-iconv-dir 编码转换

# --enable-maintainer-zts 线程相关

# --enable-intl 国际化与字符编码支持
# pecl install intl    
# MAC brew 安装的ICU位置/usr/local/Cellar/icu4c/55.1
# @link http://php.net/manual/zh/intro.intl.php

# 废弃 --with-mcrypt --enable-gd-native-ttf

make
make install
mkdir -p /usr/local/php/log/
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
cp php.ini-production /usr/local/php/etc/php.ini

# 修改配置文件 php-fpm.conf
# tcp
sed -i -e "s/user = nobody/user = www/g" /usr/local/php/etc/php-fpm.conf
sed -i -e "s/group = nobody/group = www/g" /usr/local/php/etc/php-fpm.conf
# unix
sed -i -e "s/;listen.owner = nobody/listen.owner = www/g" /usr/local/php/etc/php-fpm.conf
sed -i -e "s/;listen.group = nobody/listen.group = www/g" /usr/local/php/etc/php-fpm.conf
# logs
sed -i -e "s/;error_log =/error_log =/g" /usr/local/php/etc/php-fpm.conf
sed -i -e "s/;log_level =/log_level =/g" /usr/local/php/etc/php-fpm.conf
sed -i -e "s/;slowlog = /slowlog = /g" /usr/local/php/etc/php-fpm.conf
sed -i -e "s/;request_slowlog_timeout = 0/request_slowlog_timeout = 2/g" /usr/local/php/etc/php-fpm.conf
# pm
sed -i -e "s/pm.max_children = 5/pm.max_children = 128/g" /usr/local/php/etc/php-fpm.conf
sed -i -e "s/pm.start_servers = 2/pm.start_servers = 64/g" /usr/local/php/etc/php-fpm.conf
sed -i -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 32/g" /usr/local/php/etc/php-fpm.conf
sed -i -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 128/g" /usr/local/php/etc/php-fpm.conf

# 修改配置文件 php.ini
sed -i -e "s/;date.timezone =/date.timezone = UTC/g" /usr/local/php/etc/php.ini
sed -i '/;extension=php_xsl.dll/a\zend_extension=opcache.so' /usr/local/php/etc/php.ini

# 软链
ln -s /usr/local/php/bin/php /usr/local/bin/php
ln -s /usr/local/php/bin/php-config /usr/local/bin/php-config
ln -s /usr/local/php/bin/phpize /usr/local/bin/phpize
ln -s /usr/local/php/sbin/php-fpm /usr/local/bin/php-fpm

# 安装pecl
#cd ..
#wget http://pear.php.net/go-pear.phar
#/usr/local/php/bin/php ./go_pear.phar

sleep 1
cd ..
echo "....PHP安装完成...."
sleep 1
echo "........................................"
sleep 1
echo "....开始安装Phalcon...."
sleep 2


# 开始安装Phalcon
# sudo ./install 提示找不到phpize因为sudo的环境变量里没有/usr/local/bin/phpize
git clone --depth=1 git://github.com/phalcon/cphalcon.git
cd cphalcon/build
# 如果因为内存原因安装失败,可以执行 ./ext/install
./install
sed -i '/;extension=php_xsl.dll/a\extension=phalcon.so' /usr/local/php/etc/php.ini


sleep 1
cd ..
echo "....Phalcon安装完成...."
sleep 1
echo "........................................"
sleep 1
echo "....全部安装完成...."
sleep 1
echo "....可能需要配置的文件如下...."
echo "........................................"
echo "/usr/local/nginx/conf"
echo "/usr/local/mysql/my.cnf"
echo "........................................"


sleep 1
cd ..
echo "........................................"
sleep 1
echo "....开始安装PHP Redis拓展...."
wget https://github.com/phpredis/phpredis/archive/develop.zip -O phpredis.zip
unzip phpredis.zip
cd phpredis-develop
phpize
./configure
make && make install
sed -i '/;extension=php_xsl.dll/a\extension=redis.so' /usr/local/php/etc/php.ini


# composer
cd /root/
curl -sS https://getcomposer.org/installer | /usr/local/bin/php
mv composer.phar /usr/local/bin/composer.phar


# phpMyAdmin
# 登录不上则修改config.inc.php的$cfg['Servers'][$i]['host']为127.0.0.1
cd /data/www
wget https://files.phpmyadmin.net/phpMyAdmin/4.7.5/phpMyAdmin-4.7.5-all-languages.zip
unzip phpMyAdmin-4.7.5-all-languages.zip
mv phpMyAdmin-4.7.5-all-languages phpMyAdmin
cp ./phpMyAdmin/config.sample.inc.php ./phpMyAdmin/config.inc.php 


sleep 1
cd ..
echo "........................................"
sleep 1
echo "....开始安装Redis...."
sleep 2
mkdir -p /data/redis/
wget http://download.redis.io/releases/redis-4.0.2.tar.gz
tar zxf redis-4.0.2.tar.gz
cd redis-4.0.2
make PREFIX=/usr/local/redis install
cp redis.conf /usr/local/redis/
ln -s /usr/local/redis/bin/redis-server /usr/local/bin/redis-server
ln -s /usr/local/redis/bin/redis-cli /usr/local/bin/redis-cli
# 配置文件
sed -i -e "s/daemonize no/daemonize yes/g" /usr/local/redis/redis.conf
sed -i -e "s/logfile \"\"/logfile \"\/data\/redis\/redis.log\"/g" /usr/local/redis/redis.conf
sed -i -e "s/dir .\//dir \/data\/redis\//g" /usr/local/redis/redis.conf

# 禁用危险指令 CONFIG, FLUSHALL, FLUSHDB
# 产品环境不使用KEYS对性能影响很大
# sed -i -e "s/port 6379/port 6379/g" /usr/local/redis/redis.conf
sed -i '/# bind 127.0.0.1/a\bind 127.0.0.1' /usr/local/redis/redis.conf
sed -i -e "s/# rename-command CONFIG \"\"/rename-command CONFIG \"\"/g" /usr/local/redis/redis.conf
sed -i '/^rename-command CONFIG/a\rename-command FLUSHALL \"\"' /usr/local/redis/redis.conf
sed -i '/^rename-command CONFIG/a\rename-command FLUSHDB f671c157a1a449f9c8d31e8594e25df2' /usr/local/redis/redis.conf


# python2.7 MySQL, Redis 拓展
# 需要安装 python-devel
yum install -y python-devel
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
pip install redis
pip install pytz
pip install MySQL-python
pip install torndb

# ........................................................................................................................
# 数据同步
# https://github.com/alibaba/otter/wiki/Manager_Quickstart

