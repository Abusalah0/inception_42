#!/bin/sh

set -e

# Check if admin password file exists in secrets
if [ -f /run/secrets/portainer_admin_password ]; then
    ADMIN_PASSWORD=$(cat /run/secrets/portainer_admin_password)
    
    # Start Portainer in the background
    /opt/portainer/portainer &
    PORTAINER_PID=$!
    
    # Wait for Portainer to start
    echo "Waiting for Portainer to start..."
    sleep 5
    
    curl -X POST http://localhost:9000/api/users/admin/init \
      -H "Content-Type: application/json" \
      -d "{\"Username\":\"admin\",\"Password\":\"${ADMIN_PASSWORD}\"}" \
      2>/dev/null || echo "Admin already initialized or API call failed"
    
    # Bring Portainer back to foreground
    wait $PORTAINER_PID
else
    echo "Warning: No admin password secret found, starting without pre-configured admin"
    exec /opt/portainer/portainer
fi
