#!/bin/sh
     # Apply custom Dropbear configuration to remove DirectInterface restriction
     uci set dropbear.main.enable='1'
     uci set dropbear.main.PasswordAuth='on'
     uci set dropbear.main.RootPasswordAuth='on'
     uci set dropbear.main.Port='22'
     uci delete dropbear.main.DirectInterface 2>/dev/null || true
     # uci set dropbear.main.BannerFile='/etc/banner'  # Uncomment if needed

     # Commit changes
     uci commit dropbear

     # Remove this script after execution
     rm -f /etc/uci-defaults/99_dropbear_setup
