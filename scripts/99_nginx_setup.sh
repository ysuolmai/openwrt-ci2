#!/bin/sh
   # Apply custom Nginx configuration to disable HTTPS and enable HTTP
   cat << EOF > /etc/config/nginx
   config main global
       option uci_enable 'true'

   config server '_lan'
       list listen '80'
       list listen '[::]:80'
       option server_name '_lan'
       list include 'restrict_locally'
       list include 'conf.d/*.locations'
       option access_log 'off; # logd openwrt'
   EOF

   # (Optional) Configure uhttpd to avoid port conflict
   cat << EOF > /etc/config/uhttpd
   config uhttpd 'main'
       option listen_http '0.0.0.0:8080'
       option listen_https ''
       option home '/www'
       option cgi_prefix '/cgi-bin'
       option script_timeout '60'
       option network_timeout '30'
   EOF

   # Remove this script after execution
   rm -f /etc/uci-defaults/99_nginx_setup
