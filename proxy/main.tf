terraform {
  required_version = ">= 0.12.28"
}

provider "local" {
  version = "~> 1.4"
}

resource "local_file" "haproxy_config" {
  filename        = "${path.module}/haproxy.cfg"
  file_permission = "0644"

  content = templatefile("${path.module}/haproxy.cfg.tmpl", {
    backends = [
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
  })
}
