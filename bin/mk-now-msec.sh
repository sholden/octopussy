#!/bin/bash -x
mysql_path=$(which mysql)
mysql_dir=$(echo $mysql_path | sed 's/\/bin\/mysql//')
mariadb_path=/usr/local/Cellar/mariadb/
mariadb_version=$(mysql -V | awk 'match($0,/[0-9]+\.[0-9]+\.[0-9]+/) {print substr($0,RSTART,RLENGTH)}' | sed 's/^ *//')
mariadb_include_path="$mariadb_path$mariadb_version/include/mysql"
mariadb_plugin_path="$mariadb_path$mariadb_version/lib/plugin/" 
gcc -shared -fPIC -o ext/now_msec.so ext/now_msec.cc -I $mariadb_include_path
sudo cp -rfp ext/now_msec.so $mariadb_plugin_path
