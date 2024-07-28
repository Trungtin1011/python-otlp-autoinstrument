# amazon-ecs-otlp

**Repo Owner**: trungtin

Build and Deploy applications on Amazon ECS with OpenTelemetry Auto-Instrumentation.

Normally, AWS recommends user to use AWS Distro for OpenTelemetry (ADOT) collector for tracing.

This repository aims to use the original open-source OpenTelemetry Collector instead of ADOT collector.

### Repository structure
1. Folder [dotnet-autoinstrument](./dotnet-autoinstrument) contains source code to build required images for .NET autoinstrumentation application.
2. Folder [python-autoinstrument](./python-autoinstrument) contains source code to build required images for Python autoinstrumentation application.
3. Folder [normal-python-flask](./normal-python-flask) contains source code to build a sample Python Flask application on Amazon ECS.
4. Folder [terraform-example](./terraform-example) demostrate how to create and configure an OpenTelemetry Collector on Amazon ECS using Terraform.

<br>

### Deploy Python auto-instrumentation application on ECS

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

For detailed example of environment variables, go through the [README](./python-autoinstrument/README.md) file to understand more.

There are many other environment variables in the concept of OpenTelemetry, which can be found at [Python Zero-code Instrumentation](https://opentelemetry.io/docs/zero-code/python/configuration/#environment-variables).


<br>

### Deploy .NET auto-instrumentation application on ECS

The procedures of deploying sample .NET application with auto-instrumentation is mostly identical with that of Python:
1. Build the images `service`, `mssql`, and `client` located in [dotnet-autoinstrument](./dotnet-autoinstrument) folder.
2. Upload these images to somewhere that Amazon ECS can connect to and pull these images.
3. Create ECS services for the .NET application. You can define 1 service contains all 3 containers or 3 services hosting 3 different containers.

**Note**: Each service that needed to be auto-instrumented must also has some environment variables defined as well:
- `OTEL_SERVICE_NAME`: The name of the service running in the container. If not define, the service name collected in the OpenTelemetry Collector will be `unknown_service`.
- `OTEL_RESOURCE_ATTRIBUTES`: Additional attributes to include in the service data when sending to the OpenTelemetry Collector.
- `OTEL_EXPORTER_OTLP_ENDPOINT`: Endpoint of the OpenTelemetry Collector.
- `OTEL_EXPORTER_OTLP_PROTOCOL`: Protocol used, default to `http/protobuf`
- `OTEL_TRACES_EXPORTER`: The exporting method for traces, should be `otlp` because we are sending data to OpenTelemetry Collector using OpenTelemetry Protocol (otlp)
- `OTEL_METRICS_EXPORTER`: The exporting method for metrics, should be `otlp`, change value to `none` to disable.
- `OTEL_LOGS_EXPORTER`: The exporting method for logs, should be `otlp`, change value to `none` to disable.


In additional to those environment variables, 2 .NET container `service` and `client` **MUST** have the below environment variables defined as well:
1. `CORECLR_ENABLE_PROFILING`=1
2. `CORECLR_PROFILER`="{918728DD-259F-4A6A-AC2B-B85E1B658318}"
3. `CORECLR_PROFILER_PATH`="/otel-dotnet-auto/linux-x64/OpenTelemetry.AutoInstrumentation.Native.so"
4. `DOTNET_ADDITIONAL_DEPS`="/otel-dotnet-auto/AdditionalDeps"
5. `DOTNET_SHARED_STORE`="/otel-dotnet-auto/store"
6. `DOTNET_STARTUP_HOOKS`="/otel-dotnet-auto/net/OpenTelemetry.AutoInstrumentation.StartupHook.dll"
7. `OTEL_DOTNET_AUTO_HOME`="/otel-dotnet-auto"

For detailed example of environment variables, go through the [README](./dotnet-autoinstrument/README.md) file to understand more.

<br>
