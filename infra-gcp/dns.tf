provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "cloudflare_zone" "site-zone" {
  name = var.domain
}

resource "cloudflare_record" "record" {
  zone_id = data.cloudflare_zone.site-zone.id
  name    = var.subdomain
  value   = google_compute_address.ip.address
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "supernode-record" {
  zone_id = data.cloudflare_zone.site-zone.id
  name    = "supernode.${var.subdomain}"
  value   = google_compute_address.ip.address
  type    = "A"
  proxied = false
}
