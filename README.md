# Example configuration for Vault cluster with Consul backend 

The code in this repository was created by [Brian Green](https://github.com/greenbrian)
In order to set up Vault working in Cluster mode, an HA Backend is required. The recommended backend is Consul. Please refer to the Backend Reference on https://www.vaultproject.io/docs/config/ for more information.

This section outlines some installation steps. At a high level they are as follows:
Install service account users (users ‘vault’ and ‘consul’)
Install Vault and Consul binaries 
Install Systemd scripts and dependencies

First service account users should be configured. The following script will require sudo/root permissions and will configure users on either Ubuntu or RHEL based systems.  

Usage:
```
chmod +x setup-user.sh
./setup-user.sh vault
./setup-user.sh consul
```
The executable binaries for both Vault Enterprise and Consul Enterprise should be installed in a common location with proper permissions, as well as configuration and data directories. 

The following locations and permissions are recommended for the Vault executable:

```
sudo chmod 0755 /usr/local/bin/vault
sudo chown vault:vault /usr/local/bin/vault
sudo mkdir -pm 0755 /etc/vault.d
sudo mkdir -pm 0755 /etc/ssl/vault
```

The following is recommended for the Consul executable:
```
sudo chmod 0755 /usr/local/bin/consul
sudo chown consul:consul /usr/local/bin/consul
sudo mkdir -pm 0755 /etc/consul.d
sudo mkdir -pm 0755 /opt/consul/data
```

In order to run the applications on modern Linux operating systems a Systemd unit file is required for both Consul and Vault. [This example](vault.service)  can be used as a reference Systemd file for Vault.

RHEL location: /etc/systemd/system/vault.service
Ubuntu location: /lib/systemd/system/vault.service

[This other example](consul.service) can be used as a reference Systemd file for Consul:

RHEL location: /etc/systemd/system/consul.service
Ubuntu location: /lib/systemd/system/consul.service

Vault should only be started once the Consul cluster is formed. There is an [additional script](consul-online.sh) and [Systemd configuration](consul-online.service) that performs Consul cluster validation.

RHEL location: /etc/systemd/system/consul-online.service
Ubuntu location: /lib/systemd/system/consul-online.service

RHEL location: /etc/systemd/system/consul-online.target
Ubuntu location: /lib/systemd/system/consul-online.target

Permissions should be configured appropriately and then the services can be enabled.
```
sudo chmod 0664 /etc/systemd/system/{vault*,consul*}
sudo chmod 0664 /lib/systemd/system/{vault*,consul*}
Sudo chmod 0755 /usr/bin/consul-online.sh
sudo systemctl enable vault.service
sudo systemctl enable consul.service
```

Vault and Consul both require configuration files.

[Here](vault-no-tls.hcl) is a Vault configuration file without TLS enabled, to be placed in /etc/vault.d/vault-no-tls.hcl

[Here](vault-tls.hcl) is a Vault configuration file with TLS enabled, to be placed in /etc/vault.d/vault-tls.hcl

The storage configuration specifies where to store the data. Data will be stored encrypted at rest, and only available to vault after the unseal process.

[Here](consul.json) is a Consul configuration file for our environment, to be placed in /etc/consul.d/consul.json
Note that there are several configuration entries that should be changed to match the specific details of the test environment.

```
bootstrap_expect: This value should match the total number of Consul servers (usually 3 or 5)
advertise_addr: This value should match the private IP address of the local server
retry_join: This value should be a list of IP addresses of the other nodes in the cluster
```
The configuration directories and files should have permissions set appropriately as well.
```
sudo chown -R consul:consul /etc/consul.d /opt/consul
sudo chmod -R 0644 /etc/consul.d/*
sudo chown -R vault:vault /etc/vault.d /etc/ssl/vault
sudo chmod -R 0644 /etc/vault.d/*
```

Once the installation steps are completed on all nodes, Vault and Consul services can be started on each server with the following commands:
```
sudo systemctl start vault.service
sudo systemctl start consul.service
```

For ease of testing, environment variables can be set by creating a profile script, located in [/etc/profile.d/vault.sh](vault.sh)

Ensure permissions are set properly for the above script

```
chmod +x /etc/profile.d/vault.sh
```
