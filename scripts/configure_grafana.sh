#!/bin/bash

declare -a summary

# This script will check to see if anonymous auth is enabled on grafana. It will enable for the duration of the script and then disable it once the script is complete.

# Check if Grafana is running
if [ "$(docker ps -q -f name=grafana)" ] || [ "$(ps -ef | grep grafana-server | grep -v grep)" ]; then
    echo "Grafana is running. Proceeding with the script..."
    summary+=("Detected Grafana is running.")
else
    echo "Grafana is not running. Exiting..."
    summary+=("Grafana is not running.")
    echo "Summary of operations:"
    printf "%s\n" "${summary[@]}"
    exit 1
fi

# Create a prometheus data source via the Grafana API and skip if the data source already exists
echo "Checking if Prometheus data source already exists..."
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://admin:admin@localhost:3000/api/datasources/name/Prometheus)
if [ "$STATUS" -eq 200 ]; then
    echo "Prometheus data source already exists. Skipping..."
    summary+=("Prometheus data source already exists. Skipped creation.")
else
    echo "Prometheus data source does not exist. Creating..."
    curl -X POST -H "Content-Type: application/json" -d '{"name":"Prometheus","type":"prometheus","url":"http://localhost:9090","access":"proxy","isDefault":true}' http://admin:admin@localhost:3000/api/datasources
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://admin:admin@localhost:3000/api/datasources/name/Prometheus)
    if [ "$STATUS" -eq 200 ]; then
        echo "Prometheus data source was created successfully."
        summary+=("Successfully created Prometheus data source.")
    else
        echo "There was a problem creating the Prometheus data source. Exiting..."
        summary+=("Failed to create Prometheus data source.")
        echo "Summary of operations:"
        printf "%s\n" "${summary[@]}"
        exit 1
    fi
fi

RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://admin:admin@localhost:3000/api/datasources/name/Prometheus)
if [ "$RESPONSE" -eq 200 ]; then
    echo "Prometheus data source was created successfully."
else
    echo "There was a problem creating the Prometheus data source. Exiting..."
    summary+=("Failed to create or verify Prometheus data source.")
    echo "Summary of operations:"
    printf "%s\n" "${summary[@]}"
    exit 1
fi

# Print the summary
echo "Summary of operations:"
printf "%s\n" "${summary[@]}"
