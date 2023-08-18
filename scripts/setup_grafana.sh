#!/bin/bash
set -e
# set -x

declare -a summary

# This script will install Grafana and import default node-exporter dashboards.

# Check if Grafana image exists
if [ "$(docker images -q grafana)" ]; then
    echo "Grafana image exists. Creating Grafana container..."
    docker run -d --name grafana -p 3000:3000 grafana
    exit 0
fi

# Check if Grafana container exists
if [ "$(docker ps -aq -f status=exited -f name=grafana)" ]; then
    echo "Grafana container exists. Starting Grafana container..."
    docker start grafana
    exit 0
fi

# Check if Grafana container is already running
if [ "$(docker ps -q -f name=grafana)" ]; then
    echo "Grafana container is already running. Exiting..."
    exit 1
fi

# Install Grafana
echo "Installing Grafana..."
docker run -d --name grafana -p 3000:3000 grafana

# Wait for Grafana to start
echo "Waiting for Grafana to start..."
sleep 10

# Import default node-exporter dashboards
echo "Importing default node-exporter dashboards..."

# Get Grafana container IP address
grafana_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' grafana)

