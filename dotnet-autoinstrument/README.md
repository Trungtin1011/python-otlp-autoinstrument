# .NET auto-instrumentation demo on Amazon ECS

&nbsp;

## Service

.NET service listens to port `5000/TCP`.

Default endpoint is: `0.0.0.0:5000`

To build Service image, run command `docker build -t dotnet/autoins/service:1.0.0 ./build/Service/`.

The service requires connection to MSSQL server on port `1433/TCP`. The connection chain is defined through environment variable `DB_CONNECTION`.

To build Database image, run command `docker build -t dotnet/mssql:1.0.0 ./build/Database/`.


&nbsp;

## Client

.NET client sends continuous requests to **Service**.

Must define environment variable named `SERVICE_ENDPOINT` that point to the server endpoint in the form of: `http://server_ip:5000`

To build Client image, run command `docker build -t dotnet/autoins/client:1.0.0 ./build/Client/`.


&nbsp;

## Environment variables

Example environment variables on each image should look like:
```
mssql = {
  environment = [
    { name = "ACCEPT_EULA", value = "Y" },
    { name = "SA_PASSWORD", value = "password" },
    { name = "MSSQL_PID", value = "Developer" }
  ]
}
---
service = {
  environment = [
    # Enable OpenTelemetry .NET Automatic Instrumentation
    { name = "CORECLR_ENABLE_PROFILING", value = "1" },
    { name = "CORECLR_PROFILER", value = "{918728DD-259F-4A6A-AC2B-B85E1B658318}" },
    { name = "CORECLR_PROFILER_PATH", value = "/otel-dotnet-auto/linux-x64/OpenTelemetry.AutoInstrumentation.Native.so" },
    { name = "DOTNET_ADDITIONAL_DEPS", value = "/otel-dotnet-auto/AdditionalDeps" },
    { name = "DOTNET_SHARED_STORE", value = "/otel-dotnet-auto/store" },
    { name = "DOTNET_STARTUP_HOOKS", value = "/otel-dotnet-auto/net/OpenTelemetry.AutoInstrumentation.StartupHook.dll" },
    { name = "OTEL_DOTNET_AUTO_HOME", value = "/otel-dotnet-auto" },

    # Application envs
    { name = "DB_CONNECTION", value = "Server=mssql-ip,1433;User=sa;Password=Strongpwd@123;TrustServerCertificate=True;" },
    { name = "OTEL_SERVICE_NAME", value = "dotnet-autoins-service" },
    { name = "OTEL_RESOURCE_ATTRIBUTES", value = "container.name=service,service.name=dotnet-autoins-service,service.version=1.0.0" },
    { name = "OTEL_DOTNET_AUTO_TRACES_ADDITIONAL_SOURCES", value = "Examples.Service" },
    { name = "OTEL_DOTNET_AUTO_METRICS_ADDITIONAL_SOURCES", value = "Examples.Service" },
    { name = "OTEL_EXPORTER_OTLP_ENDPOINT", value = "http://otel-collecto:4318" },
    { name = "OTEL_EXPORTER_OTLP_PROTOCOL", value = "http/protobuf" },
    { name = "OTEL_TRACES_EXPORTER", value = "otlp" },
    { name = "OTEL_METRICS_EXPORTER", value = "none" },
    { name = "OTEL_LOGS_EXPORTER", value = "none" },
  ]
}
---
client = {
  environment = [
    # Enable OpenTelemetry .NET Automatic Instrumentation
    { name = "CORECLR_ENABLE_PROFILING", value = "1" },
    { name = "CORECLR_PROFILER", value = "{918728DD-259F-4A6A-AC2B-B85E1B658318}" },
    { name = "CORECLR_PROFILER_PATH", value = "/otel-dotnet-auto/linux-x64/OpenTelemetry.AutoInstrumentation.Native.so" },
    { name = "DOTNET_ADDITIONAL_DEPS", value = "/otel-dotnet-auto/AdditionalDeps" },
    { name = "DOTNET_SHARED_STORE", value = "/otel-dotnet-auto/store" },
    { name = "DOTNET_STARTUP_HOOKS", value = "/otel-dotnet-auto/net/OpenTelemetry.AutoInstrumentation.StartupHook.dll" },
    { name = "OTEL_DOTNET_AUTO_HOME", value = "/otel-dotnet-auto" },

    # Application envs
    { name = "SERVICE_ENDPOINT", value = "http://service-ip:5000" },
    { name = "OTEL_SERVICE_NAME", value = "dotnet-autoins-client" },
    { name = "OTEL_RESOURCE_ATTRIBUTES", value = "container.name=client,service.name=dotnet-autoins-client,service.version=1.0.0" },
    { name = "OTEL_EXPORTER_OTLP_ENDPOINT", value = "http://otel-collector:4318" },
    { name = "OTEL_EXPORTER_OTLP_PROTOCOL", value = "http/protobuf" },
    { name = "OTEL_TRACES_EXPORTER", value = "otlp" },
    { name = "OTEL_METRICS_EXPORTER", value = "none" },
    { name = "OTEL_LOGS_EXPORTER", value = "none" },
  ]
}
```
