FROM debian:11

RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && \
    curl -L https://github.com/portainer/portainer/releases/download/2.21.4/portainer-2.21.4-linux-amd64.tar.gz -o /tmp/portainer.tar.gz && \
    mkdir -p /opt/portainer && tar -xzf /tmp/portainer.tar.gz -C /opt/portainer --strip-components=1 && \
    rm /tmp/portainer.tar.gz

EXPOSE 9443
CMD ["/opt/portainer/portainer"]
