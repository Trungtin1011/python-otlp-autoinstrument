locals {
  parameters = {
    "/config/collector.yaml" = {
      description = "SSM Parameter for config file"
      type        = "SecureString"
      #secure_type          = true
      tier                 = "Standard"
      data_type            = "text"
      ignore_value_changes = false
      value                = <<-EOT
        extensions:
          health_check:
            endpoint: 0.0.0.0:13133
            path: "/health"
            response_body:
              healthy: "Service OK"
              unhealthy: "Service not OK"
        receivers:
          awscontainerinsightreceiver: # Requires containerInsights to be enabled
            collection_interval: 30s
            container_orchestrator: ecs
          awsecscontainermetrics:
            collection_interval: 30s
          otlp:
            protocols:
              grpc:
                endpoint: 0.0.0.0:4317
              http:
                endpoint: 0.0.0.0:4318
        processors:
          filter/ecs:
            error_mode: ignore
            metrics:
              metric:
                - >-
                  name != "ecs.task.memory.reserved" and
                  name != "ecs.task.memory.utilized" and
                  name != "ecs.task.cpu.reserved" and
                  name != "ecs.task.cpu.utilized" and
                  name != "ecs.task.network.rate.rx" and
                  name != "ecs.task.network.rate.tx" and
                  name != "ecs.task.storage.read_bytes" and
                  name != "ecs.task.storage.write_bytes" and
                  name != "container.duration"
        exporters:
          debug:
            verbosity: detailed
        service:
          extensions: [health_check]
          pipelines:
            traces:
              receivers: [otlp]
              processors: []
              exporters: [debug]
            metrics:
              receivers: [otlp]
              processors: []
              exporters: [debug]
            # metrics/aws:
            #   receivers: [awsecscontainermetrics]
            #   processors: [filter/ecs]
            #   exporters: [debug]
        EOT
    }
  }

}
