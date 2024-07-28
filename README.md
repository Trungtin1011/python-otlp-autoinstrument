# amazon-ecs-otlp

**Repo Owner**: trungtin

Build and Deploy applications on Amazon ECS with OpenTelemetry Auto-Instrumentation.

Normally, AWS recommends user to use AWS Distro for OpenTelemetry (ADOT) collector for tracing.

This repository aims to use the original open-source OpenTelemetry Collector instead of ADOT collector.

### Repository structure
1. Folder [dotnet-autoinstrument](./dotnet-autoinstrument) contains source code to build required images for .NET autoinstrumentation application.
2. Folder [python-autoinstrument](./python-autoinstrument) contains source code to build required images for Python autoinstrumentation application.
3. Folder [normal-python-flask](./normal-python-flask) contains source code to build a sample Python Flask application on Amazon ECS.
4. Folder [terraform-example](./terraform-example) demostrate how to create and configure an OpenTelemetry Collector on Amazon ECS.
