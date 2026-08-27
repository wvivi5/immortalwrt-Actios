#!/bin/sh
# Non-blocking cold-boot/network recovery for frpc.
# procd remains the supervisor; this only reconciles a lost connection.

ip route 2>/dev/null | grep -q '^default ' || exit 0

server_addr="$(uci -q get frpc.common.server_addr)"
[ -n "$server_addr" ] || server_addr="$(uci -q get frpc.common.serverAddr)"
server_port="$(uci -q get frpc.common.server_port)"
[ -n "$server_port" ] || server_port="$(uci -q get frpc.common.serverPort)"
[ -n "$server_addr" ] && [ -n "$server_port" ] || exit 0

# Avoid restarting for a transient DNS/route failure; the next network event
# or minute will retry. The TCP connect check is the actual frps reachability.
nc -z -w 3 "$server_addr" "$server_port" 2>/dev/null || exit 0

if ! pidof frpc >/dev/null 2>&1 || \
   ! netstat -nt 2>/dev/null | grep -F "$server_addr:$server_port" | grep -q ESTABLISHED; then
	logger -t frpc-watchdog "network is ready but frpc control connection is absent; restarting"
	/etc/init.d/frpc restart >/dev/null 2>&1 || true
fi

exit 0
