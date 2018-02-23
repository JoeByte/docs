#!/bin/sh

install_path='/tmp/Downloads'
mkdir -p ${install_path}

# 安装autoconf 【phalcon会用到】
cd ${install_path}
curl -O http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
tar zxvf autoconf-2.69.tar.gz
cd autoconf-2.69
./configure
make && make install


# 安装pcre
cd ${install_path}
curl -O https://ftp.pcre.org/pub/pcre/pcre-8.41.tar.gz
tar zxvf pcre-8.41.tar.gz
cd pcre-8.41
./configure
make && make install

# 安装openssl
cd ${install_path}
curl -O https://www.openssl.org/source/openssl-1.1.0g.tar.gz
tar zxvf openssl-1.1.0g.tar.gz
cd openssl-1.1.0g
./config
make && make install


# 安装nginx
cd ${install_path}
curl -O http://nginx.org/download/nginx-1.12.2.tar.gz
tar zxvf nginx-1.12.2.tar.gz
cd nginx-1.12.2
./configure --with-http_stub_status_module --with-http_ssl_module
make && make install


# 安装PHP
cd ${install_path}
curl -s https://php-osx.liip.ch/install.sh | bash -s 7.1


# 安装phalcon
cd ${install_path}
git clone --depth=1 "git://github.com/phalcon/cphalcon.git"
cd cphalcon/build
sudo ./install
cd /usr/local/php5/php.d
touch 50-extension-phalcon.ini
echo 'extension=phalcon.so' > 50-extension-phalcon.ini

# 安装MySql
cd ${install_path}
curl -O https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.21-macos10.13-x86_64.tar.gz
tar zxvf mysql-5.7.21-macos10.13-x86_64.tar.gz
mv mysql-5.7.21-macos10.13-x86_64 /usr/local/mysql
cd /usr/local/mysql/bin
mkdir -p /data/mysql
ln -s /data/mysql /usr/local/mysql/data
chown -R mysql:mysql /usr/local/mysql/data
./mysqld --initialize --user=mysql --basedir=/usr/local/mysql —explicit_defaults_for_timestamp





