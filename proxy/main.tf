terraform {
  required_version = ">= 0.12.28"
}

provider "local" {
  version = "~> 1.4"
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
  ]
}

resource "local_file" "haproxy_config" {
  filename        = "${path.module}/haproxy.cfg"
  file_permission = "0644"

  content = templatefile("${path.module}/haproxy.cfg.tmpl", {
    backends = var.backends
  })
}
