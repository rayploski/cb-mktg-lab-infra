job "ghost" {
  datacenters = ["mktg-lab"]
  type        = "service"

  group "ghost" {
    count = 1

    volume "ghost_content" {
      type      = "host"
      read_only = false
      source    = "ghost_content"
    }

    network {
      port "http" {
        static = 2368
        to     = 2368
      }
    }

    task "ghost" {
      driver = "docker"

      config {
        image = "ghost:5-alpine"
        ports = ["http"]
      }

      volume_mount {
        volume      = "ghost_content"
        destination = "/var/lib/ghost/content"
        read_only   = false
      }

      env {
        url                              = "http://ghost.corestory.ai"
        database__client                 = "mysql"
        database__connection__host       = "10.1.0.4"
        database__connection__user       = "ghost"
        database__connection__password   = "ghostpass"
        database__connection__database   = "ghost"
      }

      service {
        name = "ghost"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.ghost.rule=Host(`ghost.corestory.ai`)",
          "traefik.http.routers.ghost.entrypoints=web,websecure",
          "traefik.http.routers.ghost.tls=true",
          "traefik.http.routers.ghost.tls.certresolver=letsencrypt",
          "traefik.http.routers.ghost.tls.domains[0].main=ghost.corestory.ai",
          "traefik.http.services.ghost.loadbalancer.server.port=2368"
        ]

        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}
