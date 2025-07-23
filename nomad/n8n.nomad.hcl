job "n8n" {
  datacenters = ["mktg-lab"]
  type = "service"

  group "n8n-group" {
    count = 1

    network {
      port "http" {
        static = 5678
        to     = 5678
      }
    }


    task "n8n" {
      driver = "docker"

      config {
        image = "n8nio/n8n:latest"
        ports = ["http"]
      }

      env {
        N8N_BASIC_AUTH_ACTIVE   = "true"
        N8N_BASIC_AUTH_USER     = "admin"
        N8N_BASIC_AUTH_PASSWORD = "crowdbotics"
        WEBHOOK_URL             = "https://n8n.corestory.ai"
        N8N_PORT                = "5678"
        N8N_SECURE_COOKIE       = "false"
        N8N_TEMPLATES_ENABLED   = "true"
        N8N_METRICS             = "true"
        VUE_APP_URL_BASE_API    = "https://n8n.corestory.ai"
      }

      resources {
        cpu    = 500
        memory = 512
      }

      service {
        name = "n8n"
        port = "http"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.n8n.rule=Host(`n8n.corestory.ai`)",
          "traefik.http.services.n8n.loadbalancer.server.port=5678",
          "traefik.http.routers.n8n.entrypoints=web,websecure",
          "traefik.http.routers.n8n.tls.certresolver=letsencrypt"
        ]

        check {
          type     = "http"
          path     = "/healthz"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
