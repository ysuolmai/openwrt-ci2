#!/bin/sh
uci set ttyd.@ttyd[0].command='/bin/ash'
uci commit ttyd
/etc/init.d/ttyd restart
