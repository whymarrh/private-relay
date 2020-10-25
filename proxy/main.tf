terraform {
  required_version = "~> 0.13.5"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 1.4"
    }
  }
}

variable "backends" {
  description = "The set of backend servers for HAProxy"
  type = list(object({
    name = string
    host = string
    port = string
  }))

  default = [
    {
      name = "github"
      host = "api.github.com"
      port = "443"
    },
    {
      name = "httpbin"
      host = "httpbin.org"
      port = "443"
    },
    {
      name = "ifconfig"
      host = "ifconfig.co"
      port = "443"
    },
    {
      name = "ipify"
      host = "api.ipify.org"
      port = "443"
    },
  ]
}

resource "local_file" "haproxy_config" {
  filename        = "${path.module}/haproxy.cfg"
  file_permission = "0644"

  content = templatefile("${path.module}/haproxy.cfg.tmpl", {
    backends = var.backends
  })
}
