provider "docker" {
  version = "~> 2.7"
}

resource "docker_image" "private_relay_github" {
  name         = "private-relay:github"
  keep_locally = true
}

resource "docker_image" "private_relay_httpbin" {
  name         = "private-relay:httpbin"
  keep_locally = true
}

resource "docker_container" "private_relay_github" {
  image    = docker_image.private_relay_github.latest
  name     = "private-relay-github"
  must_run = true
  restart  = "on-failure"
  ports {
    internal = 443
    external = 8080
  }
}

resource "docker_container" "private_relay_httpbin" {
  image    = docker_image.private_relay_httpbin.latest
  name     = "private-relay-httpbin"
  must_run = true
  restart  = "on-failure"
  ports {
    internal = 443
    external = 9090
  }
}
