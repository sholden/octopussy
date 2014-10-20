#!/bin/sh

/hbase/bin/start-hbase.sh

sleep 5

/hbase/bin/hbase rest start

/habase/bin/stop-hbase.sh