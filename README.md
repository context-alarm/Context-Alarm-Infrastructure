# Context-Alarm-Infrastructure

Terraform configuration for creating **Context Alarm** infrastructure with multiple Ubuntu LXC containers on Proxmox VE, **with Docker pre-installed**.

## 🏗️ Infrastructure Overview

Creates a complete Context Alarm system with 4 specialized containers:

| Service | Hostname | Purpose | Resources |
|---------|----------|---------|-----------|
| 🎨 **Frontend** | frontend | Web UI | 2 CPU, 2GB RAM, 6GB disk, 512MB swap |
| 🚀 **API** | api | Backend API | 2 CPU, 2GB RAM, 6GB disk, 512MB swap |
| ✅ **Checker** | checker | Background checks | 2 CPU, 2GB RAM, 6GB disk, 512MB swap |
| 🧰 **Jenkins** | jenkins | CI/CD | 2 CPU, 2GB RAM, 6GB disk, 512MB swap |

## ✨ Key Features

✅ **Docker Pre-installed** - Custom template with Docker & Docker Compose ready  
✅ **Lightning Fast Deployment** - No provisioning delays  
✅ **Static IP Configuration** - Predictable networking  
✅ **Container Nesting Enabled** - Run Docker inside LXC  
✅ **Multiple Container Management** - Infrastructure as Code  

## 📋 Prerequisites

1. **Proxmox VE server** accessible via HTTPS
2. **Terraform** installed on your machine
3. **Custom Docker template** (we'll create this)
4. **SSH access** to Proxmox server

## 🚀 Quick Setup

### Step 1: Create Custom Docker Template

**On your Proxmox server**, create a template with Docker pre-installed:

```bash
# SSH into Proxmox
ssh root@proxmox.newsloop.xyz

# Create temporary container
pct create 9999 local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst \
  --hostname docker-template \
  --cores 2 --memory 2048 \
  --net0 name=eth0,bridge=vmbr0,ip=dhcp \
  --features nesting=1 \
  --unprivileged 1 \
  --storage nas --rootfs nas:10

# Start and enter container
pct start 9999
pct enter 9999

# Install Docker (inside container)
apt-get update && apt-get upgrade -y
apt-get install -y ca-certificates curl gnupg lsb-release software-properties-common

# Add Docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# Install Docker
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Configure Docker for LXC
mkdir -p /etc/docker
cat > /etc/docker/daemon.json << 'EOF'
{
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

# Enable Docker
systemctl enable docker
systemctl start docker

# Test installation
docker run --rm hello-world

# Clean up and exit
apt-get autoremove -y && apt-get autoclean
history -c
exit

# Create template (back on Proxmox host)
pct stop 9999
vzdump 9999 --compress gzip --mode stop --dumpdir /var/lib/vz/template/cache
mv /var/lib/vz/template/cache/vzdump-lxc-9999-*.tar.gz /var/lib/vz/template/cache/ubuntu-22.04-docker.tar.gz
pct destroy 9999

# Verify template
ls -la /var/lib/vz/template/cache/ubuntu-22.04-docker.tar.gz
```

### Step 2: Configure Terraform

```bash
# Clone or navigate to your project
cd Context-Alarm-Infrastructure

# Copy example configuration (if needed)
cp terraform.tfvars.example terraform.tfvars

# Edit with your Proxmox details
nano terraform.tfvars
```

**Required settings in `terraform.tfvars`:**

```hcl
# Proxmox Connection
proxmox_api_url      = "https://proxmox.newsloop.xyz:8006/api2/json"
proxmox_user         = "root@pam"
proxmox_password     = "your-password"
proxmox_node         = "nipunak"

# Template Settings
ubuntu_template = "local:vztmpl/ubuntu-22.04-docker.tar.gz"  # Your custom template
storage_pool    = "nas"
network_bridge  = "vmbr0"
gateway_ip      = "10.10.10.1"

# Container configurations are already defined for Context Alarm services
```

### Step 3: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Preview deployment
terraform plan

# Deploy all containers
terraform apply

# View container details
terraform output
```

## 🎯 Container Configuration

Each container is pre-configured in `terraform.tfvars`:

```hcl
containers = {
  frontend = {
    hostname        = "frontend"
    password        = "your-secure-password"
    vmid            = 140
    cpu_cores       = 2
    memory_mb       = 2048
    swap_mb         = 512
    disk_size       = "6G"
    ip_address      = "dhcp"
    gateway         = ""
    auto_start      = true
    enable_nesting  = true
    tags            = "terraform frontend docker"
  }
  api = {
    hostname        = "api"
    password        = "your-secure-password"
    vmid            = 141
    cpu_cores       = 2
    memory_mb       = 2048
    swap_mb         = 512
    disk_size       = "6G"
    ip_address      = "dhcp"
    gateway         = ""
    auto_start      = true
    enable_nesting  = true
    tags            = "terraform api docker"
  }
  checker = {
    hostname        = "checker"
    password        = "your-secure-password"
    vmid            = 142
    cpu_cores       = 2
    memory_mb       = 2048
    swap_mb         = 512
    disk_size       = "6G"
    ip_address      = "dhcp"
    gateway         = ""
    auto_start      = true
    enable_nesting  = true
    tags            = "terraform checker docker"
  }
  jenkins = {
    hostname        = "jenkins"
    password        = "your-secure-password"
    vmid            = 143
    cpu_cores       = 2
    memory_mb       = 2048
    swap_mb         = 512
    disk_size       = "6G"
    ip_address      = "dhcp"
    gateway         = ""
    auto_start      = true
    enable_nesting  = true
    tags            = "terraform jenkins docker"
  }
}
```

## 🔧 Management Commands

```bash
# View all containers
terraform output container_details

# Get IP addresses
terraform output container_ips

# Get SSH commands
terraform output container_ssh_commands

# Deploy specific container
terraform apply -target="proxmox_lxc.ubuntu_containers[\"context-alarm-keycloak\"]"

# Destroy specific container  
terraform destroy -target="proxmox_lxc.ubuntu_containers[\"context-alarm-api\"]"

# Format code
terraform fmt

# Validate configuration
terraform validate
```

## 🌐 Accessing Containers

All containers start with **Docker ready to use**:

```bash
# Access any container (use IPs from outputs if using DHCP)
terraform output container_ssh_commands

# Verify Docker is running
docker --version
docker ps
docker compose version
```

## 📁 Project Structure

```
Context-Alarm-Infrastructure/
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Variable definitions  
├── terraform.tfvars        # Your configuration (not in git)
├── terraform.tfvars.example # Example configuration
├── outputs.tf              # Container information outputs
├── .gitignore              # Excluded files
└── README.md               # This file
```

## 🔍 What Gets Created

✅ **4 LXC Containers** with Ubuntu + Docker  
✅ **Static IP networking** (10.10.10.120-123)  
✅ **Container nesting enabled** for Docker  
✅ **Automatic startup** configured  
✅ **Resource allocation** optimized per service  
✅ **Proper tagging** for organization  

## 🚨 Troubleshooting

### Common Issues:

| Issue | Solution |
|-------|----------|
| **Template not found** | Verify template creation: `ls /var/lib/vz/template/cache/ubuntu-22.04-docker.tar.gz` |
| **401 Unauthorized** | Check Proxmox credentials and API access |
| **IP conflicts** | Ensure 10.10.10.120-123 are available |
| **Storage issues** | Verify `nas` storage pool exists |
| **Docker not working** | Check nesting: `cat /proc/sys/kernel/unprivileged_userns_clone` |

### Debug Commands:

```bash
# Enable detailed logging
export TF_LOG=DEBUG
terraform apply

# Test Proxmox connectivity  
curl -k https://proxmox.newsloop.xyz:8006/api2/json/version

# Check container status in Proxmox
pct list
```

## 🔐 Security Best Practices

- ✅ Never commit `terraform.tfvars` with real credentials
- ✅ Use strong passwords for container root access
- ✅ Consider API tokens instead of root passwords
- ✅ Regularly update the Docker template
- ✅ Use SSH keys for container access
- ✅ Keep Terraform state files secure

## 🚀 Deployment Benefits

### Before (with provisioners):
- ⏱️ **5-10 minutes** per container (Docker installation)
- 🌐 **Network dependent** during deployment
- 🐛 **Complex error handling** required
- 🔄 **Inconsistent results** possible

### After (with custom template):
- ⚡ **30 seconds** per container deployment
- 🔒 **No network dependencies** during creation
- ✅ **Reliable and consistent** every time
- 🧹 **Clean, simple Terraform code**

## 📊 Resource Usage

| Component | Total Resources |
|-----------|-----------------|
| **CPU Cores** | 8 cores total |
| **Memory** | 8GB RAM total |
| **Storage** | ~24GB total |
| **Swap** | 2GB total |
| **Network** | 4 static IPs |

Perfect for running the complete Context Alarm infrastructure! 🎉