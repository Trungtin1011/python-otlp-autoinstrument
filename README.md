# otlp-autoinstrument-images

**Repo Owner**: Tin Trung Ngo


## Before you begin

This repository contains demo image for `Python` OpenTelemetry Auto-Instrumentation.

The image is meant for demonstrating how to implement auto-instrumentation in a non-Kubernetes environment. For Kubernetes, use [OpenTelemetry Operator](https://github.com/open-telemetry/opentelemetry-operator) instead.

For Amazon ECS, Normally it is recommended to use AWS Distro for OpenTelemetry (ADOT) collector for container instrumentation. The images in this repository use the original open-source OpenTelemetry Collector instead of ADOT collector.


## Repository structure
1. Folder [python-flask-autoinstrument](./python-flask-autoinstrument) contains source code to build required images for Python autoinstrumentation application.
2. Folder [normal-python-flask](./normal-python-flask) contains source code to build a sample Python Flask application on Amazon ECS.

<br>

## Deploy Python auto-instrumentation application on ECS

The concept for deploying the sample Python application with auto-instrumentation is the same as the OpenTelemetry Collector in [terraform-example](./terraform-example) folder.

The procedures may be:
1. Build the images `server` and `client` located in [python-autoinstrument](./python-autoinstrument) folder.
2. Upload these images to somewhere that Amazon ECS can connect to and pull these images.
3. Create ECS services for the Python application. You can define 1 service contains 2 containers `server` and `client` or 2 services hosting 2 different containers.

**Note**: The following environment variables are required for these 2 containers to be able to communicate with OpenTelemetry Collector:
- `OTEL_SERVICE_NAME`: The name of the service running in the container. If not define, the service name collected in the OpenTelemetry Collector will be `unknown_service`.
- `OTEL_RESOURCE_ATTRIBUTES`: Additional attributes to include in the service data when sending to the OpenTelemetry Collector.
- `OTEL_EXPORTER_OTLP_ENDPOINT`: Endpoint of the OpenTelemetry Collector.
- `OTEL_EXPORTER_OTLP_PROTOCOL`: Protocol used, default to `http/protobuf`
- `OTEL_TRACES_EXPORTER`: The exporting method for traces, should be `otlp` because we are sending data to OpenTelemetry Collector using OpenTelemetry Protocol (otlp)
- `OTEL_METRICS_EXPORTER`: The exporting method for metrics, should be `otlp`, change value to `none` to disable.
- `OTEL_LOGS_EXPORTER`: The exporting method for logs, should be `otlp`, change value to `none` to disable.


The `Python Client` container need 1 more environment variable, which is the `Python server` endpoint. It has the form of: `SERVER_ENDPOINT='http://ip_address:5000/server_request'`.

For detailed example of environment variables, go through the [README](./python-flask-autoinstrument/README.md) file to understand more.

There are many other environment variables in the concept of OpenTelemetry, which can be found at [Python Zero-code Instrumentation](https://opentelemetry.io/docs/zero-code/python/configuration/#environment-variables).


<br>

