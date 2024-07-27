from confluent_kafka import avro
from confluent_kafka.avro import AvroProducer

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
    'bootstrap.servers': 'localhost:9092',
    'schema.registry.url': 'http://localhost:8081'
    }, default_value_schema=value_schema)

def produce_job_post(job_post):
    producer.produce(topic='job_posts', value=job_post)
    producer.flush()

