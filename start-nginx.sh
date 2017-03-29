#!/bin/bash

mkdir -p /var/cache/ngx_pagespeed/cache && \
  find /var/cache/ngx_pagespeed -type d -exec chown nginx:nginx {} \; && \
  find /var/cache/ngx_pagespeed -type d -exec chmod 750 {} \; && \
  sh /etc/nginx/scripts/write_resolvers.sh && \
  exec /usr/sbin/nginx -g 'daemon off;'
