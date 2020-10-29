output "hostname" {
  description = "The DNS name associated with the load balancer."
  value       = cloudflare_load_balancer.private_relay_lb.name
}
