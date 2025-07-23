job "strapi" {
  datacenters = ["mktg-lab"]
  type        = "service"

  group "strapi" {
    count = 1

    volume "strapi_data" {
      type      = "host"
      read_only = false
      source    = "strapi_data"
    }

    network {
      port "http" {
        static = 1337
        to     = 1337
      }
    }

    task "strapi" {
      driver = "docker"

      config {
        image = "strapi/strapi:latest"
        ports = ["http"]
      }

      volume_mount {
        volume      = "strapi_data"
        destination = "/srv/app"
        read_only   = false
      }

      env {
        DATABASE_CLIENT           = "sqlite"
        NODE_ENV                 = "production"
        APP_KEYS                 = "strapi-secret-keys"
        API_TOKEN_SALT           = "api-token-salt"
        ADMIN_JWT_SECRET         = "admin-jwt-secret"
        JWT_SECRET               = "jwt-secret"
        STRAPI_DISABLE_UPDATE_NOTIFICATION = "true"
      }

      service {
        name = "strapi"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.strapi.rule=Host(`strapi.corestory.ai`)",
          "traefik.http.routers.strapi.entrypoints=web,websecure",
          "traefik.http.routers.strapi.tls=true",
          "traefik.http.routers.strapi.tls.certresolver=letsencrypt",
          "traefik.http.routers.strapi.tls.domains[0].main=strapi.corestory.ai",
          "traefik.http.services.strapi.loadbalancer.server.port=1337"
        ]

        check {
          type     = "http"
          path     = "/admin"
          interval = "15s"
          timeout  = "2s"
        }
      }

      resources {
        cpu    = 500
        memory = 768
      }
    }
  }
}
