# Python auto-instrumentation demo on Amazon ECS

&nbsp;

## Server

Flask app that listen to port `5000/TCP`.

Default endpoint is: `0.0.0.0:5000/server_request`

Build image with command: `docker build -t repo/image_name:image_tag ./server/`

&nbsp;

## Client

A Flask webapp that has a button for sending requests to **Server**.

Must define environment variable named `SERVER_ENDPOINT` that point to the server endpoint in the form of: `http://server_ip:5000/server_request`

Build image with command: `docker build -t repo/image_name:image_tag ./client/`

&nbsp;

## Environment variables

Example environment variables on each image should look like:
```
server = {
  environment = [
    { name = "OTEL_SERVICE_NAME", value = "flask-server" },
    { name = "OTEL_RESOURCE_ATTRIBUTES", value = "container.name=flask,service.name=flask-server,service.version=1.0.0" },
    { name = "OTEL_EXPORTER_OTLP_ENDPOINT", value = "http://otel-collector:4318" },
    { name = "OTEL_EXPORTER_OTLP_PROTOCOL", value = "http/protobuf" },
    { name = "OTEL_TRACES_EXPORTER", value = "otlp" },
    { name = "OTEL_METRICS_EXPORTER", value = "none" },
    { name = "OTEL_LOGS_EXPORTER", value = "none" },
  ]
}
---
client = {
  environment = [
    { name = "SERVER_ENDPOINT", value = "http://flask-server:5000/server_request" },
    { name = "OTEL_SERVICE_NAME", value = "flask-client" },
    { name = "OTEL_RESOURCE_ATTRIBUTES", value = "container.name=client,service.name=flask-client,service.version=1.0.0" },
    { name = "OTEL_EXPORTER_OTLP_ENDPOINT", value = "http://otel-collector:4318" },
    { name = "OTEL_EXPORTER_OTLP_PROTOCOL", value = "http/protobuf" },
    { name = "OTEL_TRACES_EXPORTER", value = "otlp" },
    { name = "OTEL_METRICS_EXPORTER", value = "none" },
    { name = "OTEL_LOGS_EXPORTER", value = "none" },
  ]
}
```
