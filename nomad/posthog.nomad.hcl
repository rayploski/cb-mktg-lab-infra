job "posthog" {
  datacenters = ["mktg-lab"]
  type        = "service"

  group "posthog" {
    count = 1

    network {
      port "web" {
        static = 8000
        to     = 8000
      }
    }

    task "posthog" {
      driver = "docker"

      env {
        CLICKHOUSE_HOST       = "10.1.0.4"
        CLICKHOUSE_PORT       = "9000"
        DATABASE_URL          = "postgres://posthog:posthogpass@10.1.0.4:5432/posthog"
        REDIS_URL             = "redis://10.1.0.4:6379"
        REDIS_HOST            = "10.1.0.4"
        REDIS_PORT            = "6379"
        SECRET_KEY            = "replace-with-a-secret-key"
        SITE_URL              = "https://posthog.corestory.ai"
        IS_BEHIND_PROXY       = "true"
        TRUSTED_PROXIES       = "0.0.0.0/0"
      }

      config {
        image = "posthog/posthog:latest"
        ports = ["web"]
      }

      service {
        name = "posthog"
        port = "web"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.posthog.rule=Host(`posthog.corestory.ai`)",
          "traefik.http.routers.posthog.entrypoints=web,websecure",
          "traefik.http.routers.posthog.tls=true",
          "traefik.http.routers.posthog.tls.certresolver=letsencrypt",
          "traefik.http.routers.posthog.tls.domains[0].main=posthog.corestory.ai",
          "traefik.http.services.posthog.loadbalancer.server.port=8000"
        ]
      }

      resources {
        cpu    = 1000
        memory = 4096
      }
    }
  }
}