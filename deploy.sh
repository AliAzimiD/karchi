#!/bin/bash

# Set variables
REPO_URL="https://github.com/AliAzimiD/karchi.git"
PROJECT_DIR="data-pipeline-project"

# Clone the repository
echo "Cloning the repository..."
git clone $REPO_URL

# Change to the project directory
cd $PROJECT_DIR

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
echo "Setting up Superset using Docker Compose..."
cd superset
docker-compose up -d

echo "Deployment complete. All services are up and running."

