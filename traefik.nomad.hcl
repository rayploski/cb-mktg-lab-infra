# -----------------------------------------------------------------------------------
#  Nomad Job: Traefik Reverse Proxy
# -----------------------------------------------------------------------------------
#  Description:
#    This job deploys Traefik as a reverse proxy within the "mktg-lab" datacenter.
#    It exposes HTTP traffic on port 80 and uses the Consul Catalog provider
#    for service discovery and routing.
#
#  Features:
#    - Host volume mount for dynamic configuration via /etc/traefik
#    - Exposes the Traefik dashboard (insecure mode)
#    - Registers itself with Consul for service checks
#    - Uses static port mapping for HTTP
#
#  Notes:
#    - Update the image version as needed (currently using traefik:v2.11)
#    - Ensure the "conf" host volume is defined on the Nomad client
#
# -----------------------------------------------------------------------------------


job "traefik" {
  datacenters = ["mktg-lab"]
  type        = "service"

  group "traefik" {
    count = 1

    volume "conf" {
      type      = "host"
      read_only = false
      source    = "conf"
    }

    network {
      port "http" {
        static = 80
        to     = 80
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image = "traefik:v2.11"
        ports = ["http"]
      }

      volume_mount {
        volume      = "conf"
        destination = "/etc/traefik"
        read_only   = false
      }

      template {
        data = <<EOF
[entryPoints]
  [entryPoints.web]
    address = ":80"

[api]
  dashboard = true
  insecure = true

[providers.consulCatalog]
  prefix           = "traefik"
  exposedByDefault = false

[log]
  level = "INFO"
EOF

        destination = "local/traefik.toml"
        change_mode = "restart"
      }

      service {
        name = "traefik"
        port = "http"

        tags = ["dashboard", "traefik"]
        check {
          type     = "http"
          path     = "/ping"
          interval = "10s"
          timeout  = "2s"
        }
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
