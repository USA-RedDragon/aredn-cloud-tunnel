output "public-ip" {
  value = google_compute_address.ip.address
}

output "key" {
  value     = tls_private_key.key.private_key_pem
  sensitive = true
}
