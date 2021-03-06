#!/bin/bash -x

mysql_path=$(which mysql)
mysql_dir=$(echo $mysql_path | sed 's/\/bin\/mysql//')
gcc -shared -fPIC -o ext/now_msec.so ext/now_msec.cc -I /usr/local/Cellar/mariadb/10.0.12/include/mysql
sudo cp -rfp ext/now_msec.so $mysql_dir/lib/plugin/
