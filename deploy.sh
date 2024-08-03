#!/bin/bash

# Set variables
REPO_URL="https://github.com/AliAzimiD/karchi.git"
PROJECT_DIR="$PWD/karchi/data-pipeline-project"
SUPSERSET_DIR="$PROJECT_DIR/superset"
KUBERNETES_DIR="$PROJECT_DIR/kubernetes"
MAX_RETRIES=5
RETRY_DELAY=5

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to log the current directory
log_current_directory() {
    log "Current directory: $(pwd)"
}

# Function to install kubectl
install_kubectl() {
    log "Installing kubectl..."
    sudo snap install kubectl --classic || { log "Failed to install kubectl"; exit 1; }
}

# Function to install Docker Compose
install_docker_compose() {
    log "Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose || { log "Failed to install Docker Compose"; exit 1; }
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to clone the repository
clone_repo() {
    log_current_directory
    if [ -d "karchi" ]; then
        read -p "Directory karchi already exists. Do you want to delete it and re-clone the repository? (y/n): " choice
        if [ "$choice" = "y" ]; then
            log "Deleting existing directory karchi..."
            rm -rf karchi
            log "Cloning the repository..."
            git clone $REPO_URL
        else
            log "Using existing directory karchi."
        fi
    else
        log "Cloning the repository..."
        git clone $REPO_URL || { log "Failed to clone repository"; exit 1; }
    fi

    # Move into the project directory
    cd karchi || exit 1
    log_current_directory
    git submodule init
    git submodule update
    cd ..
}

# Function to create necessary directories for Airflow
create_airflow_dirs() {
    log_current_directory
    log "Creating necessary directories for Airflow..."
    mkdir -p $PROJECT_DIR/airflow/dags
    mkdir -p $PROJECT_DIR/airflow/logs
    mkdir -p $PROJECT_DIR/airflow/plugins || { log "Failed to create directories for Airflow"; exit 1; }
}

# Function to apply Kubernetes configurations
apply_k8s_configs() {
    log_current_directory
    log "Applying Kubernetes configurations..."
    if command_exists kubectl; then
        log "Listing contents of the cloned repository before applying Kubernetes configurations:"
        ls -R $PROJECT_DIR || { log "Failed to list contents of the project directory"; exit 1; }
        
        if [ -d "$KUBERNETES_DIR" ]; then
            log "Kubernetes directory found. Applying configurations."
            cd $KUBERNETES_DIR || { log "Kubernetes directory not found: $KUBERNETES_DIR"; exit 1; }
            log_current_directory
            kubectl apply -f pv.yaml || { log "Failed to apply pv.yaml"; exit 1; }
            kubectl apply -f pvc.yaml || { log "Failed to apply pvc.yaml"; exit 1; }
            kubectl apply -f kafka-zookeeper-deployment.yaml || { log "Failed to apply kafka-zookeeper-deployment.yaml"; exit 1; }
            kubectl apply -f spark-deployment.yaml || { log "Failed to apply spark-deployment.yaml"; exit 1; }
            kubectl apply -f airflow-deployment.yaml || { log "Failed to apply airflow-deployment.yaml"; exit 1; }
        else
            log "Kubernetes directory not found after cloning: $KUBERNETES_DIR"
            log "Checking the contents of the project directory for debugging:"
            ls -la $PROJECT_DIR
            exit 1
        fi
    else
        log "kubectl is not installed. Skipping Kubernetes configurations."
    fi
}

# Function to set up Superset using Docker Compose
setup_superset() {
    log_current_directory
    log "Setting up Superset using Docker Compose..."

    # Retry mechanism for checking directory existence
    for ((i=1; i<=MAX_RETRIES; i++)); do
        if [ -d "$SUPSERSET_DIR" ]; then
            log "Superset directory found: $SUPSERSET_DIR"
            break
        else
            log "Superset directory not found. Retrying in $RETRY_DELAY seconds ($i/$MAX_RETRIES)..."
            sleep $RETRY_DELAY
        fi

        if [ $i -eq $MAX_RETRIES ]; then
            log "Superset directory not found after $MAX_RETRIES retries. Exiting."
            exit 1
        fi
    done
    
    # Navigate to the Superset directory
    cd $SUPSERSET_DIR || { log "Failed to navigate to Superset directory: $SUPSERSET_DIR"; exit 1; }
    log_current_directory
    
    # Run Docker Compose
    docker compose up -d || { log "Failed to set up Superset"; exit 1; }
}

# Main script execution
main() {
    log_current_directory

    # Install kubectl if not already installed
    if ! command_exists kubectl; then
        install_kubectl
    else
        log "kubectl is already installed"
    fi

    # Install Docker Compose if not already installed
    if ! command_exists docker-compose; then
        install_docker_compose
    else
        log "Docker Compose is already installed"
    fi

    # Clone the repository
    clone_repo

    # Create necessary directories for Airflow
    create_airflow_dirs

    # Apply the Kubernetes configurations
    apply_k8s_configs

    # Set up Superset using Docker Compose
    setup_superset

    log "Deployment complete. All services are up and running."
}

# Execute the main function
main
