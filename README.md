# Home Lab Network Monitoring Stack

8-service monitoring stack for a multi-VLAN home network built on a MikroTik CRS309-1G-8S+ core switch.

## Architecture

```
MikroTik CRS309 (UDP 1514) → rsyslog → /var/log/mikrotik.log → Promtail → Loki → Grafana
MikroTik CRS309 (SNMP v2c) → SNMP Exporter → Prometheus → Grafana
Host metrics → Node Exporter → Prometheus → Grafana
ICMP/HTTP probes → Blackbox Exporter → Prometheus → Grafana
Alert rules → Prometheus → Alertmanager → (Slack webhook)
```

## Services

| Service | Port | Purpose |
|---------|------|---------|
| Prometheus | 9090 | Metrics collection and storage |
| Grafana | 3000 | Visualization and dashboards |
| Node Exporter | 9100 | Host system metrics |
| SNMP Exporter | 9116 | MikroTik switch metrics via SNMP |
| Blackbox Exporter | 9115 | ICMP ping and HTTP probes |
| Alertmanager | 9093 | Alert routing and notifications |
| Loki | 3100 | Log aggregation |
| Promtail | 9080 | Log shipping (MikroTik syslog) |

## Network

- **Core switch:** MikroTik CRS309-1G-8S+ at 192.168.10.1
- **VLANs:** Production (10), IoT (20), Management (40), Pentesting (50)
- **Monitored devices:** MikroTik, 4x Raspberry Pi 5 (K8s cluster), Mainsail Pi, admin workstation

## Quick Start

```bash
# Start all services
docker compose up -d

# Check status
./check-status.sh

# Verify everything is healthy
./verify-monitoring.sh
```

## Monitored Targets

**Prometheus scrape targets:**
- Prometheus self-monitoring (localhost:9090)
- Admin workstation via Node Exporter (node-exporter:9100)
- MikroTik CRS309 via SNMP (192.168.10.1)

**Blackbox ICMP probes:**
- MikroTik CRS309 (192.168.10.1)
- Mainsail Pi (192.168.10.195)
- K8s nodes (192.168.10.196–199)

**Blackbox HTTP probes:**
- Mainsail web UI (192.168.10.195)

## Alert Rules

- **DeviceDown** — ICMP probe failure for 2+ minutes (critical)
- **HTTPEndpointDown** — HTTP probe failure for 2+ minutes (warning)
- **SNMPTargetUnreachable** — SNMP scrape failure for 2+ minutes (critical)
- **HighCPUUsage** — CPU above 85% for 5+ minutes (warning)
- **HighMemoryUsage** — Memory above 90% for 5+ minutes (warning)
- **DiskSpaceLow** — Disk usage above 85% for 5+ minutes (warning)
- **InterfaceDown** — Switch interface operationally down (warning)
- **HighInterfaceErrors** — Interface error rate above threshold (warning)

## MikroTik Syslog Pipeline

MikroTik sends RFC 3164 (BSD syslog) which Promtail can't parse directly. An rsyslog relay handles the format conversion:

1. MikroTik sends syslog over UDP to port 1514
2. rsyslog receives and writes to `/var/log/mikrotik.log`
3. Promtail tails the log file
4. Loki stores and indexes the logs
5. Grafana queries Loki for log visualization

The `10-mikrotik.conf` file is the rsyslog config (install to `/etc/rsyslog.d/`).

## File Structure

```
├── docker-compose.yml                    # All 8 services
├── prometheus/
│   ├── prometheus.yml                    # Scrape configs and targets
│   └── alerts.yml                        # Alert rules
├── grafana/
│   ├── provisioning/
│   │   ├── dashboards/dashboard.yml      # Dashboard auto-provisioning
│   │   └── datasources/prometheus.yml    # Prometheus + Loki datasources
│   └── dashboards/
│       ├── network-overview.json         # Network overview dashboard
│       └── mikrotik-syslog.json          # MikroTik log dashboard
├── alertmanager/alertmanager.yml         # Alert routing config
├── blackbox/blackbox.yml                 # ICMP and HTTP probe modules
├── configs/snmp.yml                      # SNMP v2c auth and IF-MIB OIDs
├── loki/loki.yml                         # Loki storage and schema config
├── promtail/promtail.yml                 # Log scrape config
├── 10-mikrotik.conf                      # rsyslog config for MikroTik
├── start-monitoring.sh                   # Quick start script
├── check-status.sh                       # Health check script
└── verify-monitoring.sh                  # Full verification script
```

## Technologies

Docker Compose, Prometheus, Grafana, Loki, Promtail, Alertmanager, SNMP Exporter, Node Exporter, Blackbox Exporter, rsyslog, MikroTik RouterOS
