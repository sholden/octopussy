FROM dockerfile/java
RUN \
    mkdir -p /hbase && \
    mkdir -p /data/hbase && \
    mkdir -p /data/zookeeper && \
    mkdir -p /hbase-package && \
    curl http://mirrors.sonic.net/apache/hbase/stable/hbase-0.98.7-hadoop2-bin.tar.gz | (cd /hbase-package; tar -xzf -) && \
    ls /hbase-package/hbase-0.98.7-hadoop2/* && \
    mv /hbase-package/hbase-0.98.7-hadoop2/* /hbase/ && \
    ls /hbase/* && \
    rm -rf /hbase-package
ADD ./hbase-site.xml /hbase/conf/hbase-site.xml
ADD ./run.sh /hbase/bin/run.sh

#Hbase REST
EXPOSE 8080

WORKDIR /hbase
CMD /hbase/bin/run.sh