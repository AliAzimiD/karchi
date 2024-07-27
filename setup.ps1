# Create directories
New-Item -ItemType Directory -Force -Path "data-pipeline-project\dags"
New-Item -ItemType Directory -Force -Path "data-pipeline-project\kafka"
New-Item -ItemType Directory -Force -Path "data-pipeline-project\spark"
New-Item -ItemType Directory -Force -Path "data-pipeline-project\kubernetes"
New-Item -ItemType Directory -Force -Path "data-pipeline-project\airflow\dags"
New-Item -ItemType Directory -Force -Path "data-pipeline-project\airflow\logs"
New-Item -ItemType Directory -Force -Path "data-pipeline-project\airflow\plugins"
New-Item -ItemType Directory -Force -Path "data-pipeline-project\superset"
New-Item -ItemType Directory -Force -Path "data-pipeline-project\logs"
New-Item -ItemType Directory -Force -Path "data-pipeline-project\data"

# Create empty files
New-Item -ItemType File -Force -Path "data-pipeline-project\dags\scrape_and_send_to_kafka.py"
New-Item -ItemType File -Force -Path "data-pipeline-project\kafka\kafka_producer.py"
New-Item -ItemType File -Force -Path "data-pipeline-project\kafka\job_post_schema.avsc"
New-Item -ItemType File -Force -Path "data-pipeline-project\spark\spark_job.py"
New-Item -ItemType File -Force -Path "data-pipeline-project\kubernetes\kafka-zookeeper-deployment.yaml"
New-Item -ItemType File -Force -Path "data-pipeline-project\kubernetes\spark-deployment.yaml"
New-Item -ItemType File -Force -Path "data-pipeline-project\kubernetes\airflow-deployment.yaml"
New-Item -ItemType File -Force -Path "data-pipeline-project\superset\docker-compose.yml"
New-Item -ItemType File -Force -Path "data-pipeline-project\README.md"

# Print success message
Write-Output "Directory structure and files created successfully."
