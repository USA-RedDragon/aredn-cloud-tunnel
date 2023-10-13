variable "project_id" {
  description = "The GCP project ID"
}

variable "region" {
  description = "The GCP region"
  default     = "us-south1"
}

variable "instance_type" {
  description = "The GCP instance type"
  default     = "e2-highcpu-2"
}

variable "server-name" {
  default     = "KI5VMF-DALLAS-GCP"
  description = "The name of the server in mesh status"
}

variable "disk-size" {
  default     = 10
  description = "The size of the disk in GB"
}

variable "cloudflare_api_token" {
  description = "The API token for Cloudflare"
  sensitive   = true
}

variable "domain" {
  default     = "mcswain.cloud"
  description = "The domain to use for the infrastructure"
}

variable "subdomain" {
  default     = "dallas.aredn"
  description = "The subdomain to use for the infrastructure"
}


variable "server-gridsquare" {
  sensitive   = true
  description = "The grid square of the server"
}

variable "server-lon" {
  sensitive   = true
  description = "The longitude of the server"
}

variable "server-lat" {
  sensitive   = true
  description = "The latitude of the server"
}

variable "pg_host" {
  sensitive   = true
  description = "The PostgreSQL host"
}

variable "pg_user" {
  sensitive   = true
  description = "The PostgreSQL user"
}

variable "pg_password" {
  sensitive   = true
  description = "The PostgreSQL password"
}

variable "pg_db" {
  sensitive   = true
  description = "The PostgreSQL database"
}

variable "session_secret" {
  sensitive   = true
  description = "The session secret"
}

variable "password_salt" {
  sensitive   = true
  description = "The password salt"
}

variable "extra_cors_hosts" {
  sensitive   = true
  default     = ""
  description = "The extra CORS hosts"
}

variable "init_admin_user_password" {
  sensitive   = true
  description = "The initial admin user password"
}

variable "extra_supernode_cors_hosts" {
  sensitive   = true
  default     = ""
  description = "The extra CORS hosts for supernode"
}

variable "vtun_starting_address" {
  default = "172.29.180.16"
}

variable "vtun_starting_address_supernode" {
  default = "172.28.180.16"
}

variable "wireguard_tap_address" {
  default     = "10.184.4.136"
  description = "The AREDN address to use for the WireGuard interface to tap into the mesh"
}

variable "wireguard_peer_publickey" {
  description = "The public key of the WireGuard peer"
  sensitive   = true
}

variable "wireguard_server_privatekey" {
  description = "The private key of the WireGuard server"
  sensitive   = true
}

variable "node_ip" {
  description = "The IP address of the node"
  sensitive   = true
}

variable "supernode_zone" {
  description = "The DNS zone for this supernode"
  sensitive   = true
}

variable "reservation_name" {
  default     = ""
  description = "The reservation name for the instance"
}
