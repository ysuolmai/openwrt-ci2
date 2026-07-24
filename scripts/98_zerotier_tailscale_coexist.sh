#!/bin/sh

# Prevent ZeroTier from selecting Tailscale as an underlay. Without this,
# both overlays can recursively carry each other's traffic.
uci -q set zerotier.global='zerotier'
uci -q set zerotier.global.local_conf_path='/etc/zerotier.local.conf'
uci -q commit zerotier

exit 0
