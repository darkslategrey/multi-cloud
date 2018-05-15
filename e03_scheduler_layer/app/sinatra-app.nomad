job "sinatraapp" {
  region = "europe"
  datacenters = ["europe-west1"]
  # datacenters = ["dc1"]

  type = "service"

  update {
    canary       = 1
    max_parallel = 1
  }

  group "webs-sinatra" {
    count = 2

    restart {
      attempts = 3
      delay    = "30s"
      interval = "2m"
      mode = "delay"
    }

    task "sinatra-server" {
      driver = "docker"

      config {
        image = "courseur/ruby-sinatra"
        port_map = {
          http = 80
        }
      }

      service {
        port = "http"
        tags = [
          "traefik.frontend.rule=Host:sinatra.exemple.com",
          "traefik.tags=exposed"
        ]
      }

      resources {
        cpu    = 200
        memory = 64

        network {
          mbits = 10
          port "http" {
            # static = 8080
          }
        }
      }
    }
  }
}
