# Temporal Kubernetes Example

An example to test Temporal with several components in Kubernetes, inluding:

- Keda
- Flux
- Kubernets CronJobs
- PostgreSQL

## Requirements

- k3d
- make
- golang 1.22.3
- docker (vanilla, Docker Desktop, or Rancher Desktop)

# Setup

Run ./run.sh

Postgres will be running on :30000
Temporal UI will be running on :30001
