job "http-echo" {
  region = "europe"
  datacenters = ["europe-west1"]

  type = "service"

  group "server" {
    count = 1

    task "http-echo" {
      driver = "docker"

      config {
        image        = "hashicorp/http-echo"
        # network_mode = "host"
        # privileged  = true
        args = ["-text", "bonjour chez vous"]
        port_map = {
          http = 5678
        }
      }

      service {
        port = "http"
        tags = [
          "http-echo",
          "http-echo-${NOMAD_ALLOC_INDEX}",
          "traefik.frontend.rule=Host:http-echo.courseur.com",
          "traefik.tags=exposed"
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

        network {
          mbits = 5

          port "http" {
            # static = 3000
          }
        }
      }
    }
  }
}
