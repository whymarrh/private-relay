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

  validation {
    condition     = length(var.backends) > 0
    error_message = "The set of backends must be non-empty."
  }

  validation {
    condition     = length([for backend in var.backends : backend.name]) == length(distinct([for backend in var.backends : backend.name]))
    error_message = "The set of backends must have unique names."
  }

  validation {
    condition     = length([for backend in var.backends : backend.host]) == length(distinct([for backend in var.backends : backend.host]))
    error_message = "The set of backends must have unique hosts."
  }
}

resource "local_file" "haproxy_config" {
  filename        = "${path.module}/haproxy.cfg"
  file_permission = "0644"

  content = templatefile("${path.module}/haproxy.cfg.tmpl", {
    backends = var.backends
  })
}
