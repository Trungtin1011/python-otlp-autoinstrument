# Base image
FROM python:alpine3.20

# Running every next command wih this user
USER root

# Creating work directory in docker
WORKDIR /usr/app

# Copying files to docker
ADD . '/usr/app'

# Installing Flask App
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# Install opentelemetry bootstrap
RUN opentelemetry-bootstrap -a install

EXPOSE 8082

# Starting application
ENTRYPOINT ["opentelemetry-instrument", "python", "client.py"]