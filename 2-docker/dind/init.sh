#!/bin/sh
set -e

echo "[init] Starting dnsmasq..."
# Start dnsmasq to provide DNS for the docker containers
dnsmasq --no-daemon --log-facility=- &
dnsmasq_pid=$!
trap "echo '[init] Stopping dnsmasq...'; kill $dnsmasq_pid" EXIT
echo "[init] dnsmasq started with PID $dnsmasq_pid"

echo "[init] Starting Docker with network bootstrap..."

# --- 1. Enable IPv4 forwarding so NAT works
sysctl -w net.ipv4.ip_forward=1 >/dev/null

# --- 2. Start Docker daemon in background (standard entrypoint)
#      We run the official entrypoint so all defaults/envs still apply.
#      "$@" will usually contain dockerd args from CMD or ARGS.
echo "[init] Launching dockerd..."
/usr/local/bin/dockerd-entrypoint.sh "$@" &
dockerd_pid=$!

# --- 3. Wait until dockerd responds to info (bridge creation)
echo "[init] Waiting for dockerd to become ready..."
until docker info >/dev/null 2>&1; do
  sleep 0.5
done
echo "[init] dockerd is up."

# --- 4. Wait for docker0 interface to exist (bridge)
until ip link show docker0 >/dev/null 2>&1; do
  sleep 0.2
done

# --- 5. Detect the bridge subnet and outbound interface dynamically
SUBNET=$(ip route show | awk '/docker0/ {print $1}')
IFACE=$(ip route | awk '/default/ {print $5}')
echo "[init] Detected docker bridge: $SUBNET -> outbound: $IFACE"

# --- 6. Add MASQUERADE rule if it doesn't exist
if ! iptables -t nat -C POSTROUTING -s "$SUBNET" -o "$IFACE" -j MASQUERADE 2>/dev/null; then
  echo "[init] Adding NAT rule for $SUBNET via $IFACE"
  iptables -t nat -A POSTROUTING -s "$SUBNET" -o "$IFACE" -j MASQUERADE
else
  echo "[init] NAT rule already present."
fi

# --- 7. Keep dockerd in foreground (forward signals)
echo "[init] Initialization complete. Handing control to dockerd (PID $dockerd_pid)"
wait $dockerd_pid
