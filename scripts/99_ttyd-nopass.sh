#!/bin/sh
uci set ttyd.@ttyd[0].command='/bin/login -f root'
uci set ttyd.@ttyd[0].interface='0.0.0.0'
uci commit ttyd
/etc/init.d/ttyd restart
