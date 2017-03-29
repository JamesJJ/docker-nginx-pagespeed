FROM debian:stable-slim

ARG SGNGX_VERSION
ENV SGNGX_VERSION ${SGNGX_VERSION:-jj_nginx_pagespeed_unknown}

ARG INSTALL_NGINX_VERSION
ENV INSTALL_NGINX_VERSION ${INSTALL_NGINX_VERSION:-1.10.3}

ARG INSTALL_PAGESPEED_VERSION
ENV INSTALL_PAGESPEED_VERSION ${INSTALL_PAGESPEED_VERSION:-latest-stable}

RUN apt-get update && apt-get upgrade -y
ONBUILD RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y --no-install-recommends \
      curl \
      sudo \
      build-essential \
      zlib1g-dev \
      libpcre3 \
      libpcre3-dev \
      unzip \
      wget \
      libssl-dev \
      ca-certificates

RUN echo "USING NGINX: ${INSTALL_NGINX_VERSION}" && \
      echo "USING PAGESPEED: ${INSTALL_PAGESPEED_VERSION}" && \
      curl -f -L -sS https://ngxpagespeed.com/install | tee install_ngxpagespeed.bash && \
      bash install_ngxpagespeed.bash \
      --assume-yes \
      --ngx-pagespeed-version ${INSTALL_PAGESPEED_VERSION} \
      --nginx-version ${INSTALL_NGINX_VERSION} \
      --dynamic-module \
      --additional-nginx-configure-arguments '\
        --with-http_ssl_module \
        --with-http_gzip_static_module \
        --with-file-aio \
        --with-http_v2_module \
        --with-http_stub_status_module \
        --with-http_realip_module \
        --without-http_autoindex_module \
        --without-http_browser_module \
        --without-http_memcached_module \
        --without-http_userid_module \
        --without-mail_pop3_module \
        --without-mail_imap_module \
        --without-mail_smtp_module \
        --without-http_split_clients_module \
        --without-http_scgi_module \
        --without-http_referer_module \
        --without-http_upstream_ip_hash_module \
        --prefix=/etc/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --pid-path=/var/run/nginx.pid \
        --sbin-path=/usr/sbin \
        --modules-path=/usr/lib/nginx \
      '
RUN apt-get remove -y --auto-remove build-essential
RUN rm -Rf /root/nginx-*
RUN rm -Rf /root/ngx_pagespeed-*

RUN adduser --system --no-create-home --disabled-login --disabled-password --group nginx

ADD etc/nginx /etc/nginx
COPY start-nginx.sh /opt/start-nginx.sh

RUN mkdir -p /var/log/nginx && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    mkdir -p /var/cache/ngx_pagespeed && \
    chown -R nginx:nginx /var/cache/ngx_pagespeed && \
    chown -R root:nginx /etc/nginx/* && \
    find /etc/nginx -type d -exec chmod g+rx,g-w,o-rwx {} \; && \
    find /etc/nginx -type f -exec chmod g+r,g-wx,o-rwx {} \; && \
    chown root:root /opt/start-nginx.sh && \
    chmod 750 /opt/start-nginx.sh

CMD /opt/start-nginx.sh

