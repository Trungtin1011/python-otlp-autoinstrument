# Python auto-instrumentation demo on AWS ECS

&nbsp;

## Server

Flask app that listen to port 5000/TCP.

Default endpoint is: 0.0.0.0:5000/server_request

Build image with command: `docker build -t repo/image_name:image_tag ./server/`

&nbsp;

## Client 

A Flask webapp that has a button for sending requests to **Server**.

Must define environment variable named `SERVER_ENDPOINT` that point to the server endpoint in the form of: `http://server_ip:5000/server_request`

Build image with command: `docker build -t repo/image_name:image_tag ./client/`

&nbsp;