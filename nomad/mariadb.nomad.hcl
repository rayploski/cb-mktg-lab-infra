job "mariadb" {
  datacenters = ["mktg-lab"]
  type = "service"

  group "mariadb" {
    count = 1

    network {
      port "db" {
        static = 3306
        to     = 3306
      }
    }

    task "mariadb" {
      driver = "docker"

      config {
        image = "mariadb:10.6"
        ports = ["db"]

        volumes = [
          "mariadb_data:/var/lib/mysql"
        ]
      }

      env {
        MYSQL_ROOT_PASSWORD = "strongpass"
        MYSQL_DATABASE      = "ghost"
        MYSQL_USER          = "ghost"
        MYSQL_PASSWORD      = "ghostpass"
      }

      service {
        name = "mariadb"
        port = "db"

        tags = [
          "traefik.enable=false"
        ]

        check {
          type     = "tcp"
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
