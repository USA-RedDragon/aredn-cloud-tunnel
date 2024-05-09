terraform {
  backend "s3" {
    bucket = "mcswain-dev-tf-states"
    key    = "aredn-cloud-tunnel"
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.48.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.32.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu-jammy" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-*-server-*"]
  }

  filter {
    name   = "architecture"
    values = [var.arch]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_eip" "ip" {
  instance = aws_instance.node.id
  domain   = "vpc"
}

resource "aws_instance" "node" {
  ami           = data.aws_ami.ubuntu-jammy.id
  instance_type = var.instance-type

  user_data = templatefile("${path.module}/user-data.sh", {
    server_name                     = var.server-name
    server_lon                      = var.server-lon
    server_lat                      = var.server-lat
    server_gridsquare               = var.server-gridsquare
    wireguard_tap_address           = var.wireguard_tap_address
    region                          = var.region
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
  user_data_replace_on_change = true

  vpc_security_group_ids = [aws_security_group.allow-vpn.id]

  key_name = aws_key_pair.key.key_name

  availability_zone = "${var.region}a"

  root_block_device {
    volume_type = "gp2"
    volume_size = var.disk-size
  }

  tags = {
    Name = var.server-name
  }
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key" {
  key_name   = var.server-name
  public_key = tls_private_key.key.public_key_openssh
}


resource "aws_security_group" "allow-vpn" {
  name        = "${var.server-name}-vpn"
  description = "Security Group for VTun VPN"

  ingress {
    from_port   = 5525
    to_port     = 5525
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5526
    to_port     = 5526
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9001
    to_port     = 9001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9002
    to_port     = 9002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
