FROM alpine:3.20

RUN apk update && apk add --no-cache mariadb mariadb-client

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld \
    && mkdir -p /var/lib/mysql && chown -R mysql:mysql /var/lib/mysql

COPY conf/my.cnf /etc/my.cnf.d/wp.cnf
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/setup.sh"]
