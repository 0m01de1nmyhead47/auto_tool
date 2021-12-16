#!/bin/bash

##yumリポジトリの整備

echo "include_only=.jp" >> /etc/yum/pluginconf.d/fastestmirror.conf

rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el8-2.noarch.rpm

rpm -Uvh https://repo.zabbix.com/zabbix/5.4/rhel/8/x86_64/zabbix-release-5.4-1.el8.noarch.rpm

sed -i -e '21s/^ /#/g' /etc/yum.repos.d/mysql-community.repo
sed -i -e '22i enabled=1' /etc/yum.repos.d/mysql-community.repo
sed -i -e '29s/^ /#/g' /etc/yum.repos.d/mjysql-community.repo
sed -i -e '30i enabled=1' /etc/yum.repos.d/mysql-community.repo

yum clean all

##install
##########################

yum -y install mysql-community-server mysql-community-client

systemctl start mysqld
systemctl enable mysqld

yum -y install zabbix-web-mysql zabbix-web-japanese zabbix-web zabbix-server-mysql zabbix-sender zabbix-agent zabbix-get

##mysqlパスワード削除
echo "SET PASSWORD = 'Mysql0123#';" | mysql -uroot -p$(cat /var/log/mysqld.log | grep "root@localhost: " | sed -e "s/^ .*A temporary password is generated for root@localhost: //g") --connect-expired-password

echo "uninstall plugin validate_password;" | mysql -uroot -pMysql0123#
echo "SET PASSWORD = '';" | mysql -uroot -pMysql0123#
sed -i -e '22i character-set-server=utf8mb4' /etc/my.cnf
systemctl restart mysqld

##zabbixセッティング
echo "create database zabbix character set utf8 collate utf8_bin;" | mysql -uroot
echo "create user zabbix@localhost identified by 'zabbix';" | mysql -uroot
echo "grant all privileges on zabbix.* to zabbix@localhost;" | mysql -uroot

zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -pzabbix zabbix

sed -i -e '116i DBPassword=zabbix' /etc/zabbix/zabbix_server.conf
sed -i -e '352i CacheSize=128M' /etc/zabbix/zabbix_server.conf

systemctl start zabbix-server
systemctl enable zabbix-server

sed -i -e '15s/^ /#/g' /etc/httpd/conf.d/zabbix.conf
sed -i -e '16i \        php_value post_max_filesize 64M' /etc/httpd/conf.d/zabbix.conf
sed -i -e '17s/^ /#/g' /etc/httpd/conf.d/zabbix.conf
sed -i -e '18i \        php_value upload_max_filesize 64M' /etc/httpd/conf.d/zabbix.conf
sed -i -e '20i \        php_value date.timezone Asia/Tokyo' /etc/httpd/conf.d/zabbix.conf

sed -i -e '14s/^ /#/g' /etc/httpd/conf.d/zabbix.conf
sed -i -e '15i \        php_value memory_limit 256M' /etc/httpd/conf.d/zabbix.conf

systemctl stop firewalld.service
systemctl disable firewalld.service

setenforce 0
sed -i -e '7s/^ /#/g' /etc/selinux/config
sed -i -e '8i SELINUX=diabled' /etc/selinux/config

sed -i -e '405s/^ /;/g' /etc/php.ini
sed -i -e '406i memory_limit 256M' /etc/php.ini

systemctl start httpd
