job "clickhouse" {
  datacenters = ["mktg-lab"]
  type        = "service"

  group "clickhouse" {
    count = 1

    volume "clickhouse_data" {
      type      = "host"
      read_only = false
      source    = "clickhouse_data"
    }

    network {
      port "http" {
        static = 8123
        to     = 8123
      }
    }

    task "clickhouse" {
      driver = "docker"

      config {
        image = "clickhouse/clickhouse-server:latest"
        ports = ["http"]
      }

      volume_mount {
        volume      = "clickhouse_data"
        destination = "/var/lib/clickhouse"
        read_only   = false
      }

      env {
        CLICKHOUSE_USER     = "admin"
        CLICKHOUSE_PASSWORD = "securepass"
      }

      resources {
        cpu    = 500
        memory = 1024
      }

      service {
        name = "clickhouse"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.clickhouse.rule=Host(`clickhouse.corestory.ai`)",
          "traefik.http.routers.clickhouse.entrypoints=web,websecure",
          "traefik.http.routers.clickhouse.tls=true",
          "traefik.http.routers.clickhouse.tls.certresolver=letsencrypt"
        ]
      }
    }
  }
}