# Dockerfile
FROM alpine:latest

# Install iptables and bash
RUN apk add --no-cache iptables bash curl tcpdump

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]