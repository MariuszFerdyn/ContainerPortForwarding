#!/bin/bash

# Use sysctl to enable IP forwarding instead of writing to read-only filesystem
sysctl -w net.ipv4.ip_forward=1
iptables -P FORWARD ACCEPT
iptables -t nat -A POSTROUTING -j MASQUERADE

# Function to add iptables port forwarding
add_port_forward() {
    local remote_host=$1
    local remote_port=$2
    local local_port=$3

    # NAT rules
    iptables -t nat -A PREROUTING -p tcp --dport "$local_port" -j DNAT --to-destination "$remote_host:$remote_port"
    iptables -t nat -A POSTROUTING -p tcp -d "$remote_host" --dport "$remote_port" -j MASQUERADE

    # Allow incoming connections on the specific local port
    iptables -A INPUT -p tcp --dport "$local_port" -j ACCEPT
    iptables -A FORWARD -p tcp --dport "$remote_port" -j ACCEPT
}
# Find and process all port forward configurations
env | grep -E "^REMOTE_HOST[0-9]*=" | while IFS='=' read -r remote_host_var remote_host; do
    # Extract the numeric suffix
    suffix=$(echo "$remote_host_var" | sed -E 's/REMOTE_HOST([0-9]*)/\1/')
    
    # Check if corresponding REMOTE_PORT and LOCAL_PORT exist
    remote_port_var="REMOTE_PORT$suffix"
    local_port_var="LOCAL_PORT$suffix"
    
    if [ -n "${!remote_port_var+x}" ] && [ -n "${!local_port_var+x}" ]; then
        add_port_forward "$remote_host" "${!remote_port_var}" "${!local_port_var}"
    fi
done

# Fallback for single set of variables (backward compatibility)
if [ -n "${REMOTE_HOST+x}" ] && [ -n "${REMOTE_PORT+x}" ] && [ -n "${LOCAL_PORT+x}" ]; then
    add_port_forward "$REMOTE_HOST" "$REMOTE_PORT" "$LOCAL_PORT"
fi

# Display all iptables NAT rules
echo "Current NAT Rules:"
iptables -t nat -L -n -v

# Display all iptables PREROUTING rules
echo -e "\nPREROUTING Rules:"
iptables -t nat -L PREROUTING -n -v

# Display all iptables POSTROUTING rules
echo -e "\nPOSTROUTING Rules:"
iptables -t nat -L POSTROUTING -n -v

# Send webhook notification if URL is provided
if [ -n "${WEBHOOKAFTERSTART+x}" ]; then
    echo -e "\nSending webhook notification to $WEBHOOKAFTERSTART..."
    webhook_response=$(curl -s -X POST "$WEBHOOKAFTERSTART" -H "Content-Type: application/json" -d "{\"status\":\"container_started\", \"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}")
    echo "Webhook response: $webhook_response"
fi

# Keep container running
exec tail -f /dev/null