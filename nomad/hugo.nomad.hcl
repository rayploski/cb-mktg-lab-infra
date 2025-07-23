job "hugo" {
  datacenters = ["mktg-lab"]
  type        = "service"

  group "hugo" {
    count = 1

    network {
      port "http" {
        static = 1313
        to     = 1313
      }
    }

    task "hugo" {
      driver = "docker"

      config {
        image = "klakegg/hugo:ext-alpine"
        args  = ["server", "--bind=0.0.0.0", "--baseURL=https://hugo.corestory.ai", "--appendPort=false"]
        ports = ["http"]
      }

      service {
        name = "hugo"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.hugo.rule=Host(`hugo.corestory.ai`)",
          "traefik.http.routers.hugo.entrypoints=web,websecure",
          "traefik.http.routers.hugo.tls=true",
          "traefik.http.routers.hugo.tls.certresolver=letsencrypt",
          "traefik.http.routers.hugo.tls.domains[0].main=hugo.corestory.ai",
          "traefik.http.services.hugo.loadbalancer.server.port=1313"
        ]

        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }

      resources {
        cpu    = 200
        memory = 256
      }
    }
  }
}