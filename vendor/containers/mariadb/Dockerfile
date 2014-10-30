FROM dockerfile/mariadb

RUN mkdir /src
ADD ./now_msec.cc /src/
RUN \
    apt-get update -qq && apt-get install -y build-essential libmariadbd-dev && \
    gcc -shared -fPIC -o /src/now_msec.so /src/now_msec.cc -I /usr/include/mysql && \
    cp -rfp /src/now_msec.so /usr/lib/mysql/plugin/ && \
    rm -rf /src && \
    apt-get purge -y --auto-remove build-essential libmariadbd-dev

# RUN DEBIAN_FRONTEND=noninteractive apt-get install -y pwgen inotify-tools

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 3306
ADD my.cnf /etc/mysql/my.cnf
# ADD usr.sbin.mysqld /etc/apparmor.d/usr.sbin.mysqld
# ADD scripts /scripts
# RUN chmod +x /scripts/start.sh
# RUN touch /firstrun

# Expose our data, log, and configuration directories.
VOLUME ["/data", "/var/log/mysql", "/etc/mysql"]

# Use baseimage-docker's init system.
# CMD ["/scripts/start.sh"]
CMD ["mysqld_safe"]

