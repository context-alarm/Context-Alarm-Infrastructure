# Context-Alarm-Infrastructure

Terraform configuration for creating Ubuntu LXC containers on Proxmox VE.

## Prerequisites

1. **Proxmox VE server** with Ubuntu container templates
2. **Terraform** installed on your machine
3. **Ubuntu template** downloaded in Proxmox

## Quick Setup

### 1. Download Ubuntu Template in Proxmox
First, download an Ubuntu container template in your Proxmox web interface:
- Go to your node → Local (storage) → CT Templates
- Click "Templates" and download Ubuntu (e.g., ubuntu-22.04-standard)

### 2. Configure Your Settings
```bash
# Copy the example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your actual values
nano terraform.tfvars
```

### 3. Deploy the Container
```bash
# Initialize Terraform (downloads Proxmox provider)
terraform init

# Preview what will be created
terraform plan

# Create the container
terraform apply
```

## Configuration Guide

### Required Settings in `terraform.tfvars`:

```hcl
# Your Proxmox server details
proxmox_api_url = "https://192.168.1.100:8006/api2/json"
proxmox_user    = "root@pam"
proxmox_password = "your-password"
proxmox_node    = "pve"  # Your Proxmox node name

# Ubuntu template (check available templates in Proxmox)
ubuntu_template = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"

# Container settings
container_hostname = "my-ubuntu-container"
container_password = "secure-password"
```

### Optional Settings:

- **Static IP**: Set `container_ip = "192.168.1.100/24"` and `gateway_ip = "192.168.1.1"`
- **SSH Keys**: Add your public key to `ssh_public_keys`
- **Resources**: Adjust `cpu_cores`, `memory_mb`, `root_disk_size`

## What Gets Created

- **LXC Container** running Ubuntu
- **Automatically started** after creation
- **Network configured** (DHCP by default)
- **Root filesystem** with specified size
- **SSH access** (if keys provided)

## Useful Commands

```bash
# Check what will be created/changed
terraform plan

# Apply changes
terraform apply

# Destroy the container
terraform destroy

# Show container info
terraform output

# Format code
terraform fmt

# Validate configuration
terraform validate
```

## Accessing Your Container

After creation, you can access your container:

```bash
# SSH (if you added SSH keys)
ssh root@<container_ip>

# Or via Proxmox console
# Go to Proxmox web interface → Container → Console
```

## File Structure

- `main.tf` - Main Terraform configuration
- `variables.tf` - Variable definitions
- `terraform.tfvars.example` - Example configuration
- `terraform.tfvars` - Your actual configuration (not in git)
- `outputs.tf` - Information displayed after creation
- `.gitignore` - Files to exclude from git

## Troubleshooting

### Common Issues:

1. **Template not found**: Check template name in Proxmox storage
2. **Permission denied**: Verify Proxmox credentials and permissions
3. **Network issues**: Check bridge name (`vmbr0` is default)
4. **Storage issues**: Verify storage pool name in Proxmox

### Debug Commands:
```bash
# Enable debug logging
export TF_LOG=DEBUG
terraform apply
```

## Security Notes

- Never commit `terraform.tfvars` with real credentials
- Use API tokens instead of passwords when possible
- Consider using remote state storage for teams
- Set strong passwords for containers