terraform {
  required_version = "~> 0.13.5"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
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
}

resource "local_file" "haproxy_config" {
  filename        = "${path.module}/haproxy.cfg"
  file_permission = "0644"

  content = templatefile("${path.module}/haproxy.cfg.tmpl", {
    backends = var.backends
  })
}
