# Terraform RKE2 Kubernetes Cluster on vSphere

This repository contains a Terraform module for deploying a **production-ready Kubernetes cluster** using **RKE2** (Rancher Kubernetes Engine 2) on a **vSphere** environment. It supports multi-AZ setups, customizable resource configurations, and secure cluster operations.

---

## Features

- **Multi-AZ Support**: High availability with master and worker nodes distributed across multiple availability zones.
- **Customizable Resources**: Define CPU, memory, and storage configurations for nodes.
- **RKE2 Integration**: Built-in RKE2 installation with support for various CNI plugins (e.g., Canal, Flannel, Calico).
- **Storage Options**: Local storage and optional NFS integration.
- **Networking Configuration**: Define service and cluster CIDRs, with secure API server access.

---

## Prerequisites

Before using this module, ensure you have the following:

1. **Terraform**: Installed and configured on your local machine.
2. **vSphere Access**: Ensure access to vSphere with proper credentials and permissions.
3. **Required Tools**: Install the following tools:
   - `python3.x`
   - `ansible`
   - `ansible-core`

---

## Quick Start Guide

### Step 1: Clone the Repository
```bash
$ git clone https://github.com/alessskeno/terraform-vsphere-rke2.git
$ cd terraform-vsphere-rke2
```

### Step 2: Configure Variables
Use the template from `terraform.tfvars.example` file or use environment variables to provide the required inputs. Below are key variables:

```hcl
domain          = "example.com"
cluster_cidr    = "10.42.0.0/16"
service_cidr    = "10.43.0.0/16"
rke2_token      = "your-rke2-cluster-token"
vsphere_host_az1 = "vSphere-host-AZ1"
vsphere_host_az3 = "vSphere-host-AZ3"
# Add other required variables as necessary
```

### Step 3: Initialize Terraform
```bash
$ terraform init
```

### Step 4: Plan and Apply
Review the plan and apply the configuration:
```bash
$ terraform plan
$ terraform apply
```

---

## Module Overview

### Main Inputs
- **Environment**: Set `env` to `prod`, `staging`, or `dev` to differentiate setups.
- **Resource Configuration**: Define `worker_node_cpus`, `worker_node_memory`, `master_node_cpus`, etc.
- **Storage Configuration**: Enable local storage with `lh_storage` or configure an NFS server.
- **Networking**: Define `cluster_cidr`, `service_cidr`, and custom IP ranges for nodes.
- **RKE2 Version**: Set `rke2_version` to ensure compatibility with your workloads.

### Outputs
- **Kubeconfig**: Access the cluster using the generated kubeconfig file.
- **Node IPs**: Lists of master and worker node IPs.

---

## Troubleshooting

### Common Issues
- **Terraform Fails to Connect**: Ensure your vSphere credentials are correct and accessible.
- **Cluster Not Ready**: Verify network CIDR settings and API server configurations.
- **Resource Exhaustion**: Increase allocated resources for master/worker nodes.

### Logs and Debugging
Check Terraform logs:
```bash
$ terraform apply -log-level=DEBUG
```

For Kubernetes issues:
```bash
$ kubectl get nodes
$ kubectl describe pod <pod-name> -n <namespace>
```

---

## Contributing

Feel free to contribute to this repository! Submit pull requests or open issues for bug fixes, improvements, or feature requests.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Contact

Have questions or need help? Reach out to me via LinkedIn or open an issue in the repository.
