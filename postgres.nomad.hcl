job "postgres" {
  datacenters = ["mktg-lab"]
  type        = "service"

  group "postgres" {
    count = 1

    volume "postgres_data" {
      type      = "host"
      read_only = false
      source    = "postgres_data"
    }

    network {
      port "db" {
        static = 5432
        to     = 5432
      }
    }

    task "postgres" {
      driver = "docker"

      config {
        image = "postgres:15-alpine"
        ports = ["db"]
      }

      env {
        POSTGRES_USER     = "posthog"
        POSTGRES_PASSWORD = "posthogpass"
        POSTGRES_DB       = "posthog"
      }

      volume_mount {
        volume      = "postgres_data"
        destination = "/var/lib/postgresql/data"
        read_only   = false
      }

      service {
        name = "postgres"
        port = "db"
        tags = ["traefik.enable=false"]
      }

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}