#!/bin/bash
# Verify Network Monitoring Stack

echo "========================================"
echo "Network Monitoring Stack Verification"
echo "========================================"
echo ""

# Check containers
echo "1. Checking Docker containers..."
docker-compose ps
echo ""

# Check Prometheus
echo "2. Checking Prometheus..."
if curl -s http://localhost:9090/-/healthy > /dev/null 2>&1; then
    echo "   ✅ Prometheus is healthy"
    echo "   URL: http://localhost:9090"
else
    echo "   ❌ Prometheus is not responding"
fi
echo ""

# Check Grafana
echo "3. Checking Grafana..."
if curl -s http://localhost:3000/api/health > /dev/null 2>&1; then
    echo "   ✅ Grafana is healthy"
    echo "   URL: http://localhost:3000"
    echo "   Login: admin/admin"
else
    echo "   ❌ Grafana is not responding"
fi
echo ""

# Check Node Exporter
echo "4. Checking Node Exporter..."
if curl -s http://localhost:9100/metrics | head -1 > /dev/null 2>&1; then
    echo "   ✅ Node Exporter is working"
else
    echo "   ❌ Node Exporter is not responding"
fi
echo ""

# Check SNMP Exporter
echo "5. Checking SNMP Exporter..."
if curl -s http://localhost:9116/metrics | head -1 > /dev/null 2>&1; then
    echo "   ✅ SNMP Exporter is working"
else
    echo "   ❌ SNMP Exporter is not responding"
fi
echo ""

# Check Prometheus targets
echo "6. Checking Prometheus targets..."
echo "   Go to: http://localhost:9090/targets"
echo "   All targets should show as 'UP'"
echo ""

echo "========================================"
echo "Next Steps:"
echo "========================================"
echo "1. Open Prometheus: http://localhost:9090"
echo "2. Open Grafana: http://localhost:3000"
echo "3. In Grafana, import dashboards"
echo "4. Verify all targets are UP"
echo ""
echo "To stop: docker-compose down"
echo "========================================"
