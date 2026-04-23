FROM alpine:3.20

RUN apk update && apk add --no-cache nginx openssl

RUN mkdir -p /etc/nginx/ssl /run/nginx /var/www/html \
    && openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
       -keyout /etc/nginx/ssl/nginx.key \
       -out /etc/nginx/ssl/nginx.crt \
       -subj "/C=LU/ST=Luxembourg/L=Luxembourg/O=42School/OU=rsommer/CN=rsommer.42.fr"

COPY conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
