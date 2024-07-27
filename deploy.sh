#!/bin/bash

# Set variables
REPO_URL="https://github.com/AliAzimiD/karchi.git"
PROJECT_DIR="karchi"

# Function to install kubectl
install_kubectl() {
    echo "Installing kubectl..."
    apt-get update && apt-get install -y apt-transport-https ca-certificates curl
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
    apt-get update && apt-get install -y kubectl
}

# Function to install Docker Compose
install_docker_compose() {
    echo "Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
}

# Install kubectl if not already installed
if ! command -v kubectl &> /dev/null; then
    install_kubectl
else
    echo "kubectl is already installed"
fi

# Install Docker Compose if not already installed
if ! command -v docker-compose &> /dev/null; then
    install_docker_compose
else
    echo "Docker Compose is already installed"
fi

# Clone the repository if it doesn't exist
if [ ! -d "$PROJECT_DIR" ]; then
    echo "Cloning the repository..."
    git clone $REPO_URL
fi

# Change to the project directory
cd $PROJECT_DIR || exit

# Create necessary directories for Airflow
echo "Creating necessary directories for Airflow..."
mkdir -p /mnt/$PROJECT_DIR/airflow/dags
mkdir -p /mnt/$PROJECT_DIR/airflow/logs
mkdir -p /mnt/$PROJECT_DIR/airflow/plugins

# Apply the Kubernetes configurations
echo "Applying Kubernetes configurations..."
kubectl apply -f kubernetes/pv.yaml
kubectl apply -f kubernetes/pvc.yaml
kubectl apply -f kubernetes/airflow-deployment.yaml

# Set up Superset using Docker Compose
if [ -d "superset" ]; then
    echo "Setting up Superset using Docker Compose..."
    cd superset || exit
    docker-compose up -d
else
    echo "Superset directory not found. Skipping Superset setup."
fi

echo "Deployment complete. All services are up and running."
