job "redis" {
  datacenters = ["mktg-lab"]
  type        = "service"

  group "redis" {
    count = 1

    volume "redis_data" {
      type      = "host"
      read_only = false
      source    = "redis_data"
    }

    network {
      port "db" {
        static = 6379
        to     = 6379
      }
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:alpine"
        ports = ["db"]
      }

      volume_mount {
        volume      = "redis_data"
        destination = "/data"
        read_only   = false
      }

      service {
        name = "redis"
        port = "db"
        tags = [
          "traefik.enable=false"
        ]
      }

      resources {
        cpu    = 250
        memory = 256
      }
    }
  }
}