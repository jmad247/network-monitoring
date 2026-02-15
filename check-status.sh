#!/bin/bash
# Quick status check for monitoring stack

echo "========================================"
echo "Monitoring Stack Status Check"
echo "========================================"
echo ""

echo "1. Docker Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "prometheus|grafana|node-exporter|snmp-exporter|NAMES"
echo ""

echo "2. Port Status:"
netstat -tulpn 2>/dev/null | grep -E ':(9090|3000|9100|9116)' || echo "No monitoring ports detected"
echo ""

echo "3. Service Health Checks:"

# Prometheus
if curl -s http://localhost:9090/-/healthy > /dev/null 2>&1; then
    echo "   ✅ Prometheus: UP (http://localhost:9090)"
else
    echo "   ❌ Prometheus: DOWN"
fi

# Grafana
if curl -s http://localhost:3000/api/health > /dev/null 2>&1; then
    echo "   ✅ Grafana: UP (http://localhost:3000)"
else
    echo "   ❌ Grafana: DOWN"
fi

# Node Exporter
if curl -s http://localhost:9100/metrics | head -1 > /dev/null 2>&1; then
    echo "   ✅ Node Exporter: UP"
else
    echo "   ❌ Node Exporter: DOWN"
fi

# SNMP Exporter
if curl -s http://localhost:9116/metrics | head -1 > /dev/null 2>&1; then
    echo "   ✅ SNMP Exporter: UP"
else
    echo "   ❌ SNMP Exporter: DOWN"
fi

echo ""
echo "========================================"
echo "If services are DOWN, check logs:"
echo "  docker-compose logs prometheus"
echo "  docker-compose logs grafana"
echo "========================================"
