output "hostname" {
  description = "The DNS name associated with the Private Relay."
  value = (
    length(cloudflare_load_balancer.private_relay_lb) == 1
    ? cloudflare_load_balancer.private_relay_lb[0].name
    : cloudflare_record.private_relay_dns_record[0].hostname
  )
}
