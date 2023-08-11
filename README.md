# Intro

This project is a simple prometheus and node exporter setup. 

## Prerequisites

- Docker
- RHEL or CentOS 8
- Ansible
- Python3

## Installation

1. Clone the repo
   
   ```sh
   git clone https://github.com/adamvialpando/prometheus-ansible.git
    ```

2. Run the playbook to prometheus and node exporter
   
   ```sh
   ansible-playbook -i inventory.ini site.yml -l <node group from inventory file>
   ```
3. Verify the installation by navigating to the following address in your preferred browser
   
   ```sh
    http://<prometheus server ip>:9090
    ```
4. Verify the node exporter is working by navigating to the following address in your preferred browser
    
    ```sh
     http://<node exporter ip>:9100/metrics
     ```

## Usage

This project is intended to be used as a simple prometheus and node exporter setup. Please feel free to modify the inventory file to fit your needs.