from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col
from pyspark.sql.types import StructType, StructField, StringType, TimestampType

# Initialize Spark session
spark = SparkSession.builder \
    .appName("KafkaSparkStreaming") \
    .config("spark.jars", "/path/to/postgresql-42.2.23.jar") \
    .getOrCreate()

# Define Kafka parameters
kafka_broker = 'localhost:9092'
kafka_topic = 'job_posts'

# Read data from Kafka
df = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", kafka_broker) \
    .option("subscribe", kafka_topic) \
    .load()

# Define schema for the incoming data
schema = StructType([
    StructField("id", StringType(), True),
    StructField("title", StringType(), True),
    StructField("company_titleFa", StringType(), True),
    StructField("company_titleEn", StringType(), True),
    StructField("province_titleFa", StringType(), True),
    StructField("province_titleEn", StringType(), True),
    StructField("city_titleFa", StringType(), True),
    StructField("city_titleEn", StringType(), True),
    StructField("country_titleFa", StringType(), True),
    StructField("country_titleEn", StringType(), True),
    StructField("workType_titleFa", StringType(), True),
    StructField("workType_titleEn", StringType(), True),
    StructField("salary", StringType(), True),
    StructField("gender", StringType(), True),
    StructField("tags", StringType(), True),
    StructField("jobBoard_titleFa", StringType(), True),
    StructField("jobBoard_titleEn", StringType(), True),
    StructField("activationTime", TimestampType(), True)
])

# Parse the JSON data and apply the schema
parsed_df = df.select(from_json(col("value").cast("string"), schema).alias("data")).select("data.*")

# Perform data processing (e.g., cleaning)
cleaned_df = parsed_df.dropna()

# JDBC connection properties
jdbc_url = "jdbc:postgresql://localhost:5432/superset"
connection_properties = {
    "user": "superset",
    "password": "superset",
    "driver": "org.postgresql.Driver"
}

# Write the cleaned data to PostgreSQL
query = cleaned_df.writeStream \
    .foreachBatch(lambda batch_df, _: batch_df.write \
        .jdbc(url=jdbc_url, table="cleaned_job_posts", mode="append", properties=connection_properties)) \
    .outputMode("update") \
    .start()

query.awaitTermination()

