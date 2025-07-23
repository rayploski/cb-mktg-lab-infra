#!/bin/bash
set -euxo pipefail

# Update system
apt-get update -y
apt-get install -y  curl gnupg software-properties-common apt-transport-https

# Add HashiCorp GPG key and repo
curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  > /etc/apt/sources.list.d/hashicorp.list

apt-get update -y
apt-get install -y vault consul nomad boundary

#-------------------- configurations -----------------------#
# Create Vault configuration
mkdir -p /etc/vault.d
mkdir -p /opt/vault
mkdir -p /opt/vault/data
cat <<EOF > /etc/vault.d/vault.hcl
# Full configuration options can be found at https://developer.hashicorp.com/vault/docs/configuration

ui = true

#mlock = true
#disable_mlock = true

storage "file" {
  path = "/opt/vault/data"
}

#storage "consul" {
#  address = "127.0.0.1:8500"
#  path    = "vault"
#}

# HTTP listener
listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = 1
}

# HTTPS listener
#listener "tcp" {
#  address       = "0.0.0.0:8200"
#  tls_cert_file = "/opt/vault/tls/tls.crt"
#  tls_key_file  = "/opt/vault/tls/tls.key"
# }


api_addr = "http://10.1.0.4:8200"
cluster_addr = "https://10.1.0.4:8201"EOF

# Create Consul configuration
mkdir -p /etc/consul.d
cat <<EOF > /etc/consul.d/consul.hcl
bind_addr = "127.0.0.1"

data_dir = "/opt/consul"

client_addr = "0.0.0.0"

datacenter = "dc1"

encrypt = "YOUR_ENCRYPTION_KEY"

server = true
bootstrap_expect = 3

retry_join = ["provider=aws tag_key=consul-cluster tag_value=c1 use_auto_scaling_groups=true"]
EOF

# Create Vault configuration
mkdir -p /etc/consul.d
mkdir -p /opt/consul
mkdir -p /opt/consul/data
cat <<EOF > /etc/consul.d/consul.hcl
datacenter = "mktg-lab"
#server     = true
bootstrap_expect = 1
data_dir   = "/opt/consul/data"
client_addr = "0.0.0.0"
ui = true


# Add these two lines:
bind_addr = "10.1.0.4"
advertise_addr = "10.1.0.4"
➜  consul.d cat consul.hcl
datacenter = "mktg-lab"
node_name  = "mktg-lab-vm1"
server     = true
bootstrap_expect = 1
data_dir   = "/opt/consul/data"
client_addr = "0.0.0.0"
ui = true


# Add these two lines:
bind_addr = "10.1.0.4"
advertise_addr = "10.1.0.4"
EOF

# Create Nomad configuration
mkdir -p /etc/nomad.d
mkdir -p /opt/nomad/data
cat <<EOF > /etc/nomad.d/nomad.hcl
data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"
region    = "global"
datacenter = "mktg-lab"
log_level = "INFO"
enable_syslog = true

server {
  enabled          = true
  bootstrap_expect = 1
}

client {
  enabled = true
  servers = ["127.0.0.1"]

  # host_volume "ghost_content" {
  #  path      = "/opt/nomad/volumes/ghost"
  #  read_only = false
  # }
}
EOF

#-------------------- systemd -----------------------#

# Create Vault systemd unit
cat <<EOF > /etc/systemd/system/vault.service
[Unit]
Description=Vault
Requires=network-online.target
After=network.target

[Service]
ExecStart=/usr/bin/vault server -config=/etc/vault.d/vault.hcl
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Create Consul systemd unit
cat <<EOF > /etc/systemd/system/consul.service
[Unit]
Description=Consul
Requires=network-online.target
After=network.target

[Service]
ExecStart=/usr/bin/consul agent -config-dir=/etc/consul.d
Restart=on-failure


[Install]
WantedBy=multi-user.target
EOF

# Create Nomad systemd unit
cat <<EOF > /etc/systemd/system/nomad.service
[Unit]
Description=Nomad
Requires=network-online.target
After=network.target

[Service]
ExecStart=/usr/bin/nomad agent -config=/etc/nomad.d
Restart=on-failure


[Install]
WantedBy=multi-user.target
EOF

# Create Boundary systemd unit
cat <<EOF > /etc/systemd/system/boundary.service
[Unit]
Description=Boundary
After=network.target

[Service]
ExecStart=/usr/bin/boundary dev
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Create Waypoint systemd unit
cat <<EOF > /etc/systemd/system/waypoint.service
[Unit]
Description=Waypoint
After=network.target

[Service]
ExecStart=/usr/bin/waypoint server run -dev
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Enable all services
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable vault consul nomad

# boundary waypoint will be added as services at a future point