from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime, timedelta
import requests
import json
from confluent_kafka import avro
from confluent_kafka.avro import AvroProducer

# Kafka configuration
kafka_broker = 'localhost:9092'
kafka_topic = 'job_posts'
schema_registry_url = 'http://localhost:8081'

value_schema_str = """
{
  "type": "record",
  "name": "JobPost",
  "fields": [
    {"name": "id", "type": "int"},
    {"name": "title", "type": "string"},
    {"name": "company_titleFa", "type": "string"},
    {"name": "company_titleEn", "type": ["null", "string"], "default": null},
    {"name": "province_titleFa", "type": "string"},
    {"name": "province_titleEn", "type": "string"},
    {"name": "city_titleFa", "type": "string"},
    {"name": "city_titleEn", "type": "string"},
    {"name": "country_titleFa", "type": "string"},
    {"name": "country_titleEn", "type": "string"},
    {"name": "workType_titleFa", "type": "string"},
    {"name": "workType_titleEn", "type": "string"},
    {"name": "salary", "type": ["null", "string"], "default": null},
    {"name": "gender", "type": "string"},
    {"name": "tags", "type": {"type": "array", "items": "string"}},
    {"name": "jobBoard_titleFa", "type": "string"},
    {"name": "jobBoard_titleEn", "type": "string"},
    {"name": "activationTime", "type": "string"}
  ]
}
"""

value_schema = avro.loads(value_schema_str)

producer = AvroProducer({
    'bootstrap.servers': kafka_broker,
    'schema.registry.url': schema_registry_url
    }, default_value_schema=value_schema)

def scrape_data():
    url = "https://api.karbord.io/api/v1/Candidate/JobPost/GetList"
    headers = {
        "Accept": "application/json, text/plain, */*",
        "Accept-Encoding": "gzip, deflate, br, zstd",
        "Accept-Language": "en-US,en;q=0.9",
        "Clientid": "2669266",
        "Content-Type": "application/json",
        "Ngsw-Bypass": "true",
        "Origin": "https://karbord.io",
        "Referer": "https://karbord.io/",
        "Sec-Ch-Ua": '"Chromium";v="122", "Not(A:Brand";v="24", "Google Chrome";v="122"',
        "Sec-Ch-Ua-Mobile": "?0",
        "Sec-Ch-Ua-Platform": '"Windows"',
        "Sec-Fetch-Dest": "empty",
        "Sec-Fetch-Mode": "cors",
        "Sec-Fetch-Site": "same-site",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    }

    data_template = {
        "isInternship": False,
        "isRemote": False,
        "location": None,
        "publishDate": None,
        "workType": None,
        "pageSize": 50,
        "page": 1,
        "sort": 0,
        "searchId": "384499690147307672",
        "jobPostCategories": [],
        "jobBoardIds": [],
        "hasNoWorkExperienceRequirement": False
    }

    response = requests.post(url, headers=headers, data=json.dumps(data_template))
    job_posts = response.json().get("data", {}).get("jobPosts", [])
    for post in job_posts:
        producer.produce(topic=kafka_topic, value=post)

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2023, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'scrape_and_send_to_kafka',
    default_args=default_args,
    description='A DAG to scrape data and send to Kafka',
    schedule_interval=timedelta(hours=4),
)

scrape_data_task = PythonOperator(
    task_id='scrape_data',
    python_callable=scrape_data,
    dag=dag,
)

scrape_data_task

