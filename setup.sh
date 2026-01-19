#!/bin/bash
# Network Monitoring Stack Setup Script

set -e

echo "=== Network Monitoring Stack Setup ==="
echo ""

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed"
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo "ERROR: Docker Compose is not installed"
    exit 1
fi

echo "Docker found: $(docker --version)"
echo ""

# Get MikroTik IP
read -p "Enter your MikroTik IP address [192.168.88.1]: " MIKROTIK_IP
MIKROTIK_IP=${MIKROTIK_IP:-192.168.88.1}

# Get SNMP community
read -p "Enter SNMP community string [monitoring]: " SNMP_COMMUNITY
SNMP_COMMUNITY=${SNMP_COMMUNITY:-monitoring}

echo ""
echo "Updating configuration files..."

# Update Prometheus config
sed -i "s/192.168.88.1/$MIKROTIK_IP/g" prometheus/prometheus.yml

# Update SNMP exporter config
sed -i "s/community: monitoring/community: $SNMP_COMMUNITY/g" snmp-exporter/snmp.yml

echo "Configuration updated!"
echo ""
echo "MikroTik IP: $MIKROTIK_IP"
echo "SNMP Community: $SNMP_COMMUNITY"
echo ""

# MikroTik SNMP setup instructions
echo "=== MikroTik SNMP Setup ==="
echo ""
echo "Run these commands on your MikroTik:"
echo ""
echo "/snmp set enabled=yes"
echo "/snmp community add name=$SNMP_COMMUNITY addresses=$(hostname -I | awk '{print $1}')/32 read-access=yes"
echo ""

read -p "Press Enter once SNMP is configured on MikroTik, or Ctrl+C to exit..."

echo ""
echo "Starting monitoring stack..."
docker compose up -d

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Access your dashboards:"
echo "  Grafana:      http://localhost:3000  (admin/admin)"
echo "  Prometheus:   http://localhost:9090"
echo "  Alertmanager: http://localhost:9093"
echo ""
echo "To view logs: docker compose logs -f"
echo "To stop:      docker compose down"
