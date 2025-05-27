#!/bin/sh

docker container prune -f
docker volume prune -a -f
docker image prune -a -f