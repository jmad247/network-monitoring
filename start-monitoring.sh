#!/bin/bash
# Start Network Monitoring Stack

cd ~/Lab/network-testing/monitoring

echo "Starting Prometheus + Grafana monitoring stack..."
docker-compose up -d

echo ""
echo "Waiting for containers to start..."
sleep 5

echo ""
docker-compose ps

echo ""
echo "========================================"
echo "Monitoring Stack Started!"
echo "========================================"
echo ""
echo "Access URLs:"
echo "  Prometheus: http://localhost:9090"
echo "  Grafana:    http://localhost:3000"
echo "              (admin/admin)"
echo ""
echo "To stop: docker-compose down"
echo "To view logs: docker-compose logs -f"
echo "========================================"
