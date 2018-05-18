job "hashi-ui" {
  region = "europe"
  datacenters = ["europe-west1"]

  type = "service"

  group "server" {
    count = 1

    task "hashi-ui" {
      driver = "docker"

      config {
        image        = "jippi/hashi-ui"
        network_mode = "host"
        privileged  = true
      }

      service {
        port = "http"
        tags = [
          "hashi-ui",
          "hashi-ui-gcp-${NOMAD_ALLOC_INDEX}",
          "traefik.frontend.rule=Host:hashi-ui.example.com",
          "traefik.tags=exposed"
        ]
        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }

      env {
        NOMAD_ENABLE = 1
        NOMAD_ADDR   = "http://nomad.service.consul:4646"

        CONSUL_ENABLE = 1
        CONSUL_ADDR   = "http://consul.service.consul:8500"
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
