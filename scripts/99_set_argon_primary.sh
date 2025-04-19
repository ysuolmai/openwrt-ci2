#!/bin/sh

if [ ! -f /etc/config/argon ]; then
    touch /etc/config/argon
    uci add argon global
fi

uci set argon.@global[0].primary='#31A1A1'
uci set argon.@global[0].dark_primary='#31A1A1'
uci set argon.@global[0].transparency='0.3'
uci set argon.@global[0].transparency_dark='0.3'
uci set argon.@global[0].blur='10'
uci set argon.@global[0].blur_dark='10'
uci commit argon
