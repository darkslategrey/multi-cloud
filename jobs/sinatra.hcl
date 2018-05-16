job "sinatra" {
  region = "global"
  datacenters = ["dc1"]

  type = "service"

  update {
    max_parallel = 1

    min_healthy_time = "10s"
    healthy_deadline = "3m"
    auto_revert = false

    canary = 0
  }

  migrate {
    max_parallel = 1

    # potential values are "checks" or "task_states".
    health_check = "checks"

    min_healthy_time = "10s"

    healthy_deadline = "5m"
  }

  group "backend" {
    count = 1

    restart {
      attempts = 2
      interval = "30m"

      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 300
    }

    task "sinatra-app" {
      driver = "docker"

      config {
        image = "sinatra:0.2"

        port_map {
          sinatra = 3000
        }
      }
      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
        network {
          mbits = 10
          port "sinatra" {
          }
        }
      }

      service {
        name = "sinatra-app"
        tags = ["global", "cache"]
        port = "sinatra"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
      # template {
      #   data          = "---\nkey: {{ key \"service/my-key\" }}"
      #   destination   = "local/file.yml"
      #   change_mode   = "signal"
      #   change_signal = "SIGHUP"
      #   env         = true
      # }

      # vault {
      #   policies      = ["cdn", "frontend"]
      #   change_mode   = "signal"
      #   change_signal = "SIGHUP"
      # }

      # Controls the timeout between signalling a task it will be killed
      # and killing the task. If not set a default is used.
      # kill_timeout = "20s"
    }
  }
}
