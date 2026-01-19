# Network Monitoring Stack

Enterprise-grade network monitoring solution using Prometheus, Grafana, and SNMP for MikroTik devices.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Docker Network                            │
│                                                                  │
│  ┌──────────┐   ┌──────────────┐   ┌─────────────────┐          │
│  │ Grafana  │◄──│  Prometheus  │◄──│  SNMP Exporter  │◄── MikroTik
│  │  :3000   │   │    :9090     │   │     :9116       │          │
│  └──────────┘   └──────────────┘   └─────────────────┘          │
│       │                │                                         │
│       │                ├──────────┬─────────────────┐           │
│       │                ▼          ▼                 ▼           │
│       │         ┌──────────┐ ┌──────────┐   ┌─────────────┐     │
│       │         │  Node    │ │ Blackbox │   │ Alertmanager│     │
│       │         │ Exporter │ │ Exporter │   │   :9093     │     │
│       │         │  :9100   │ │  :9115   │   └─────────────┘     │
│       │         └──────────┘ └──────────┘                       │
└───────┼─────────────────────────────────────────────────────────┘
        │
        ▼
   Web Browser
```

## Components

| Component | Port | Purpose |
|-----------|------|---------|
| Prometheus | 9090 | Metrics collection and storage |
| Grafana | 3000 | Visualization and dashboards |
| SNMP Exporter | 9116 | MikroTik SNMP metrics |
| Node Exporter | 9100 | Linux host metrics |
| Blackbox Exporter | 9115 | Endpoint probing (ICMP, HTTP) |
| Alertmanager | 9093 | Alert routing and notifications |

## Quick Start

### 1. Configure MikroTik SNMP

SSH into your MikroTik and run:

```routeros
/snmp set enabled=yes
/snmp community add name=monitoring addresses=YOUR_DOCKER_HOST_IP/32 read-access=yes
```

### 2. Update Configuration

Edit `prometheus/prometheus.yml` and update:
- `192.168.88.1` → Your MikroTik IP address

Edit `snmp-exporter/snmp.yml` and update:
- `community: monitoring` → Your SNMP community string (if different)

### 3. Deploy Stack

```bash
cd ~/Job/Projects/network-monitoring
docker compose up -d
```

### 4. Access Dashboards

- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Alertmanager**: http://localhost:9093

## Dashboards

### Network Overview
- MikroTik uptime
- Device status (up/down)
- Latency monitoring
- Interface traffic (in/out)
- Interface errors
- Interface operational status

### Host Metrics
- CPU usage gauge
- Memory usage gauge
- Disk usage gauge
- CPU & Memory over time
- Network traffic per interface

## Alerts

Pre-configured alerts in `prometheus/alerts.yml`:

| Alert | Condition | Severity |
|-------|-----------|----------|
| DeviceDown | ICMP probe fails for 1m | Critical |
| HighLatency | >100ms for 5m | Warning |
| SNMPTargetDown | SNMP unreachable for 2m | Critical |
| HighCPUUsage | >80% for 5m | Warning |
| HighMemoryUsage | >85% for 5m | Warning |
| DiskSpaceLow | >85% used for 5m | Warning |
| HighInterfaceUtilization | >800Mbps for 5m | Warning |
| InterfaceErrors | Any errors for 5m | Warning |

## Adding Alert Notifications

### Discord Webhook

Edit `alertmanager/alertmanager.yml`:

```yaml
receivers:
  - name: 'critical'
    webhook_configs:
      - url: 'https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_TOKEN'
        send_resolved: true
```

### Slack

```yaml
receivers:
  - name: 'critical'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'
        channel: '#alerts'
```

## Adding More Devices

### Additional MikroTik

Add to `prometheus/prometheus.yml` under `snmp-mikrotik` targets:

```yaml
- targets:
  - 192.168.88.1  # Router 1
  - 192.168.88.2  # Router 2
```

### Linux Hosts

Deploy node-exporter on remote hosts and add to prometheus:

```yaml
- job_name: 'remote-nodes'
  static_configs:
    - targets:
      - '192.168.10.10:9100'
      - '192.168.10.11:9100'
```

## Useful Commands

```bash
# Start stack
docker compose up -d

# View logs
docker compose logs -f

# Restart after config changes
docker compose restart prometheus

# Stop stack
docker compose down

# Full cleanup (removes data)
docker compose down -v
```

## File Structure

```
network-monitoring/
├── docker-compose.yml
├── prometheus/
│   ├── prometheus.yml      # Main config
│   └── alerts.yml          # Alert rules
├── grafana/
│   ├── provisioning/
│   │   ├── datasources/
│   │   │   └── datasources.yml
│   │   └── dashboards/
│   │       └── dashboards.yml
│   └── dashboards/
│       ├── network-overview.json
│       └── host-metrics.json
├── snmp-exporter/
│   └── snmp.yml            # MikroTik SNMP config
├── alertmanager/
│   └── alertmanager.yml
├── blackbox/
│   └── blackbox.yml
└── README.md
```

## Skills Demonstrated

- **Network Observability**: SNMP polling, metrics collection
- **Infrastructure as Code**: Docker Compose, configuration management
- **Monitoring & Alerting**: Prometheus rules, Alertmanager routing
- **Data Visualization**: Grafana dashboards, PromQL queries
- **Network Protocols**: SNMP v2c, ICMP, HTTP probing

## Next Steps

1. Add more devices to monitoring
2. Create custom dashboards for specific use cases
3. Set up Discord/Slack notifications
4. Add Grafana authentication (LDAP/OAuth)
5. Implement long-term storage (Thanos/Cortex)

---

**Author**: Madison
**Created**: January 2026
**License**: MIT
