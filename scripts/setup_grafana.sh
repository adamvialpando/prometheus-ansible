#!/bin/bash
set -e
# set -x

declare -a summary

# This script will install Grafana by pulling and running the latest image version.

# Check if Grafana image exists
if [ "$(docker images -q grafana)" ]; then
    echo "Grafana image exists. Creating Grafana container..."
    docker run -d --name grafana -p 3000:3000 grafana/grafana
    summary+=("Created Grafana container.")
    exit 0
fi

# Check if Grafana container exists
if [ "$(docker ps -aq -f status=exited -f name=grafana)" ]; then
    echo "Grafana container exists. Starting Grafana container..."
    docker start grafana
    summary+=("Started existing Grafana container.")
    exit 0
fi

# Check if Grafana container is already running
if [ "$(docker ps -q -f name=grafana)" ]; then
    echo "Grafana container is already running."
    summary+=("Grafana container already running. No action taken.")
    exit 1
fi

# Install Grafana
echo "Installing Grafana..."
docker run -d --name grafana -p 3000:3000 grafana/grafana
summary+=("Installed Grafana and started the container.")

# Wait for Grafana to start
echo "Waiting for Grafana to start..."
sleep 10
summary+=("Waited for Grafana to start up.")

# Get Grafana container IP address
grafana_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' grafana)
summary+=("Retrieved Grafana IP address as $grafana_ip.")

# Print the summary
echo "Summary of operations:"
printf "%s\n" "${summary[@]}"

