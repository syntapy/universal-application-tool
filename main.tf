terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "2.10.0"
    }
  }
}

# Configure Docker provider and connect to the local Docker socket
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Containers
resource "docker_container" "postgres" {
  image = docker_image.postgres.latest
  name  = "db"
  restart = "always"
  env = ["POSTGRES_PASSWORD=example"]
}

resource "docker_container" "adminer" {
  image = docker_image.adminer.latest
  name = "adminer"
  restart = "always"
  ports {
    internal = 8080
    external = 8080
  }
}

resource "docker_image" "postgres" {
  name = "postgres:latest"
}

resource "docker_image" "adminer" {
  name = "adminer:latest"
}
