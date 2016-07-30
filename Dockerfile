FROM debian:jessie

MAINTAINER Zaxk "superkevingit@gmail.com"

ENV NGINX_VERSION 1.10.1-1~jessie

# 安装nginx
RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
    && echo "deb http://nginx.org/packages/debian/ jessie nginx" >> /etc/apt/source.list \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y \
                        ca-certificates \
                        nginx=${NIGNX_VSESION} \
                        nginx-module-xslt \
                        nginx-module-geoip \
                        nginx-module-image-filter \
                        nginx-module-perl \
                        nginx-module-njs \
                        gettext-base \
    && rm -rf /var/lib/apt/lists/*

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# --------------------------------------------------------------------------------------------------------------------


RUN apt-get update \ 
    && apt-get install -y \
        nginx \
        php5-fpm \
        php5-mysqlnd \
        php5-cli \
        mysql-server \
        supervisor \
        curl \
        php5-curl \
        vim

    && apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* tmp/* var/tmp/* \

RUN curl -sS https://getcomposer.org/installer \
        | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /app

COPY ./composer.json /app/
COPY ./composer.lock /app/

RUN composer install --no-autoloader --no-scripts

COPY . /app

RUN composer install \
    && chown -R www-data:www-data /app \
    && chmod -R 0777 /app/storage

# --------------------------------------------------------------------------------------------------------------------
EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
