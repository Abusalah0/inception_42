FROM debian:11

# Install curl and ca-certificates (keep curl for the entrypoint script)
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && \
    curl -L https://github.com/portainer/portainer/releases/download/2.21.4/portainer-2.21.4-linux-amd64.tar.gz -o /tmp/portainer.tar.gz && \
    mkdir -p /opt/portainer && tar -xzf /tmp/portainer.tar.gz -C /opt/portainer --strip-components=1 && \
    rm /tmp/portainer.tar.gz && \
    rm -rf /var/lib/apt/lists/*

# Copy entrypoint script
COPY portainer-entrypoint.sh /usr/local/bin/portainer-entrypoint.sh
RUN chmod +x /usr/local/bin/portainer-entrypoint.sh

EXPOSE 9443

# Use portainer-entrypoint script to handle admin password setup
ENTRYPOINT ["/usr/local/bin/portainer-entrypoint.sh"]
