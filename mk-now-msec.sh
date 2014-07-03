#!/bin/bash -x

mysql_path=$(which mysql)
mysql_dir=$(echo $mysql_path | sed 's/\/bin\/mysql//')
gcc -shared -fPIC -o now_msec.so now_msec.cc -I /usr/local/Cellar/mariadb/5.5.34/include/mysql
sudo cp -rfp now_msec.so $mysql_dir/lib/plugin/
