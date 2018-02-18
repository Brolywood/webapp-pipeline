#!/bin/bash -v
yum install -y docker
service docker start
docker pull ${docker_image}
docker run -d -p 8080:8080 --name webapp ${docker_image}
