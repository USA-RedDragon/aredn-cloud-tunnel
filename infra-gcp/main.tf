terraform {
  backend "s3" {
    bucket = "mcswain-dev-tf-states"
    key    = "aredn-cloud-tunnel-dallas"
    region = "us-east-1"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.14.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.23.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
  required_version = ">= 1.7.2"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_compute_address" "ip" {
  name = lower(var.server-name)
}

data "google_compute_image" "ubuntu" {
  family      = "ubuntu-2204-lts"
  project     = "ubuntu-os-cloud"
  most_recent = true
}

resource "google_compute_instance" "default" {
  name                      = lower(var.server-name)
  machine_type              = var.instance_type
  zone                      = "${var.region}-b"
  allow_stopping_for_update = true

  tags = ["http-server", "https-server", "wireguard-server", "vtun-server", "vtun-supernode-server"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
      size  = var.disk-size
      type  = "pd-ssd"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.ip.address
    }
  }

  dynamic "reservation_affinity" {
    for_each = length(var.reservation_name) > 1 ? [1] : []
    content {
      type = "SPECIFIC_RESERVATION"
      specific_reservation {
        key    = "compute.googleapis.com/reservation-name"
        values = [var.reservation_name]
      }
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${trimspace(tls_private_key.key.public_key_openssh)}"
  }

  metadata_startup_script = templatefile("${path.module}/user-data.sh", {
    server_name                     = var.server-name
    server_lon                      = var.server-lon
    server_lat                      = var.server-lat
    server_gridsquare               = var.server-gridsquare
    wireguard_tap_address           = var.wireguard_tap_address
    wireguard_peer_publickey        = var.wireguard_peer_publickey
    wireguard_server_privatekey     = var.wireguard_server_privatekey
    node_ip                         = var.node_ip
    supernode_zone                  = var.supernode_zone
    pg_host                         = var.pg_host
    pg_user                         = var.pg_user
    pg_pass                         = var.pg_password
    pg_db                           = var.pg_db
    session_secret                  = var.session_secret
    password_salt                   = var.password_salt
    extra_cors_hosts                = var.extra_cors_hosts
    init_admin_user_password        = var.init_admin_user_password
    extra_supernode_cors_hosts      = var.extra_supernode_cors_hosts
    vtun_starting_address           = var.vtun_starting_address
    vtun_starting_address_supernode = var.vtun_starting_address_supernode
  })
}
