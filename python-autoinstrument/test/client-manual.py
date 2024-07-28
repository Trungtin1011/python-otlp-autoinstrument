from sys import argv
import os
from requests import get

from opentelemetry import trace
from opentelemetry.sdk.resources import Resource
from opentelemetry.propagate import inject
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace.export import (
    BatchSpanProcessor,
    ConsoleSpanExporter,
)

# Set up resource attributes
resource = Resource(attributes={
  "service.name": "python-otlp-client",
  "service.version": "1.0.0",
  "host.name": "python-otlp-client",
  "deployment.environment": "test",
  "telemetry.sdk.language": "python",
  "telemetry.sdk.name": "opentelemetry"
})

# Sets the global default TracerProvider
trace.set_tracer_provider(TracerProvider(resource=resource))
tracer = trace.get_tracer_provider().get_tracer(__name__)

# Set up BatchSpanProcessor for console and otlp export
span_processor_console = BatchSpanProcessor(ConsoleSpanExporter())
#span_processor_otlp_http = BatchSpanProcessor(OTLPSpanExporter(endpoint='http://aws-sg-trungtin-rnd-ecs-nlb-001-54da07484940b741.elb.ap-southeast-1.amazonaws.com:4318/v1/traces'))#os.environ.get('OTLP_EXPORTER_ENDPOINT')))

# Add the span processors to the tracer provider
trace.get_tracer_provider().add_span_processor(span_processor_console)
#trace.get_tracer_provider().add_span_processor(span_processor_otlp_http)

assert len(argv) == 2

with tracer.start_as_current_span("client"):

    with tracer.start_as_current_span("client-server"):
        headers = {}
        inject(headers)
        requested = get(
            "http://18.142.79.116:5000/server_request",
            #os.environ.get('SERVER_ENDPOINT'),
            params={"param": argv[1]},
            headers=headers,
        )

        assert requested.status_code == 200
