FROM alpine:3.20

RUN apk update && apk add --no-cache \
    php83 \
    php83-fpm \
    php83-mysqli \
    php83-json \
    php83-curl \
    php83-dom \
    php83-exif \
    php83-fileinfo \
    php83-mbstring \
    php83-openssl \
    php83-xml \
    php83-zip \
    php83-phar \
    php83-session \
    php83-opcache \
    php83-iconv \
    php83-gd \
    php83-intl \
    mariadb-client \
    wget \
    curl

RUN ln -sf /usr/bin/php83 /usr/bin/php \
    && echo "memory_limit = 256M" > /etc/php83/conf.d/00-memory.ini

RUN wget -q -O /usr/local/bin/wp \
    https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

RUN mkdir -p /var/www/html && chown -R nobody:nobody /var/www/html

COPY conf/www.conf /etc/php83/php-fpm.d/www.conf
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]
