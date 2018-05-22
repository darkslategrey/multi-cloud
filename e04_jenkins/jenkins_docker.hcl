job "jenkins" {
  region = "europe"
  datacenters = ["europe-west1"]

  type = "service"

  update {
    max_parallel = 1
  }

  group "front" {
    count = 1

    restart {
      attempts = 3
      delay    = "30s"
      interval = "2m"
      mode = "delay"
    }

    # constraint {
    #   attribute = "${node.class}"
    #   value     = "app"
    # }

    task "jenkins" {
      driver = "docker"

      config {
        image = "jenkins/jenkins:lts"
        port_map = {
          app = 8080
        }
        port_map = {
          slave = 50000
        }
      }

      env {
      }

      service {
        name = "jenkins"
        port = "app"
        tags = [
          "app",
          "app-gcp-${NOMAD_ALLOC_INDEX}",
          "traefik.frontend.rule=Host:jenkins.example.com",
          "traefik.tags=exposed"
        ]
      }

      resources {
        cpu    = 100
        memory = 500

        network {
          mbits = 10
          port "app" {
            # static = 8080
          }
          port "slave" {
            # static = 5050
          }
        }
      }
    }
  }
}
