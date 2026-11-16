# main.tf - the infrastructure: 1 PostgreSQL container + 1 Nginx web container

# --- Terraform settings and Docker provider ---
terraform {
  required_version = ">= 1.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Talks to the local Docker daemon (unix:///var/run/docker.sock)
provider "docker" {}

# --- 1. Database: PostgreSQL ---

# Pull the PostgreSQL image from Docker Hub
resource "docker_image" "postgres_image" {
  name         = "postgres:latest"
  keep_locally = true # do not delete the image on "terraform destroy"
}

# Create and configure the PostgreSQL container
resource "docker_container" "db_container" {
  name  = "tp-db-postgres"
  image = docker_image.postgres_image.image_id # provider v3: "image_id" (the old ".latest" was removed)

  ports {
    internal = 5432
    external = var.db_port_external # 5432 by default (see variables.tf)
  }

  # Database configuration through environment variables (values from variables.tf)
  env = [
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_DB=${var.db_name}",
  ]
}

# --- 2. Web application: Nginx ---

# Build the application image from the local Dockerfile_app
resource "docker_image" "app_image" {
  name = "tp-web-app:latest"
  build {
    context    = "."
    dockerfile = "Dockerfile_app"
  }
  # Rebuild the image when the Dockerfile or the Nginx config changes
  triggers = {
    dockerfile = filesha1("${path.module}/Dockerfile_app")
    nginx_conf = filesha1("${path.module}/app/default.conf")
  }
}

# Create the web application container
resource "docker_container" "app_container" {
  name  = "tp-app-web"
  image = docker_image.app_image.image_id

  # Explicit dependency: the database is created before the application
  depends_on = [docker_container.db_container]

  # Port 80 inside the container -> port 8080 (variable) on the host
  ports {
    internal = 80
    external = var.app_port_external
  }
}
