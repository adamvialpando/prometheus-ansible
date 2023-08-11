#!/bin/bash
set -e
set -x

declare -a summary

# Check for CLI argument
prom_install=false
if [ "$#" -ge 1 ] && [ "$1" == "prom" ]; then
    prom_install=true
fi

summary+=("CLI argument for Prometheus installation: $prom_install")

# Check if the script is running as root
is_root=false
if [ "$(id -u)" -eq 0 ]; then
    is_root=true
fi

# Check for Docker
docker_installed=$(which docker 2>/dev/null || echo "")
if [ -z "$docker_installed" ]; then
    summary+=("Docker installed: No")
else
    summary+=("Docker installed: Yes")

    # Check if Docker is running
    docker_running=$($is_root && systemctl is-active docker || sudo systemctl is-active docker)
    if [ "$docker_running" != "active" ]; then
        summary+=("Docker running: No")
    else
        summary+=("Docker running: Yes")

        # Check Docker Hub connectivity
        docker_hub_reachable=$(curl -s -o /dev/null -w '%{http_code}' https://hub.docker.com/)
        # If Docker Hub is not reachable, then exit the script with an error message suggesting to check if proxy is configured properly. 
        # Commenting out for now as it is not required. 
        # if [ "$docker_hub_reachable" -ne 200 ]; then
        #     summary+=("Docker Hub reachable: No")
        # else
        #     summary+=("Docker Hub reachable: Yes")
        # fi
    fi
fi

# Check Prometheus servers from hosts.ini
# Commenting out for now as it is not required. 

# prometheus_servers=($(awk -F'=' '/\[prometheus\]/{a=1}a==1&&$1~/^[0-9a-zA-Z]/ {print $1}' hosts.ini))
# if [ ${#prometheus_servers[@]} -eq 0 ]; then
#     summary+=("Number of Prometheus servers listed in hosts.ini: 0")
# else
#     summary+=("Number of Prometheus servers listed in hosts.ini: ${#prometheus_servers[@]}")
#     for prometheus_server in "${prometheus_servers[@]}"
#     do
#         if [[ ! $prometheus_server =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
#             echo "Invalid Prometheus server address: $prometheus_server"
#             continue
#         fi
#         prometheus_server_reachable=$(curl -s -o /dev/null -w '%{http_code}' http://$prometheus_server:9090/)
#         if [ "$prometheus_server_reachable" -eq 200 ]; then
#             summary+=("Prometheus server $prometheus_server reachable: Yes")
#         else
#             echo "Prometheus server $prometheus_server is not reachable. Please check if the Prometheus server is running and run the script again."
#             summary+=("Prometheus server $prometheus_server reachable: No")
#         fi
#     done
# fi

# Install Prometheus if required
if [ "$prom_install" = "true" ]; then
    $is_root && docker run -d -p 9090:9090 --name prometheus-server -v /etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus:latest || sudo docker run -d -p 9090:9090 --name prometheus-server -v /etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus:latest
    summary+=("Prometheus server installed: Yes")
else
    summary+=("Prometheus server installation skipped")
fi

# Docker actions
if $is_root; then
    node_exporter_exists=$(docker ps -a | grep -q node-exporter && echo "yes" || echo "no")
else
    node_exporter_exists=$(sudo docker ps -a | grep -q node-exporter && echo "yes" || echo "no")
fi

if [ "$node_exporter_exists" == "no" ]; then
    $is_root && docker run -d --name node-exporter -p 9100:9100 prom/node-exporter || sudo docker run -d --name node-exporter -p 9100:9100 prom/node-exporter
    summary+=("Node exporter container started: Yes")
else
    summary+=("Node exporter container already running")
fi

# Display summary
echo -e "\n------- Summary -------"
for item in "${summary[@]}"
do
    echo "$item"
done
