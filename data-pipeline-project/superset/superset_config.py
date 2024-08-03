SECRET_KEY = "A4q0E4xgSaihNzg5f0sQeDb1Lf0DJcVk8G0v1M8HoGRsq1j7pTHc/4Oz"

# Database configuration
SQLALCHEMY_DATABASE_URI = 'postgresql+psycopg2://superset:superset@superset_db:5432/superset'

# Redis configuration for caching
CACHE_CONFIG = {
    'CACHE_TYPE': 'RedisCache',
    'CACHE_DEFAULT_TIMEOUT': 300,
    'CACHE_KEY_PREFIX': 'superset_',
    'CACHE_REDIS_HOST': 'superset_cache',
    'CACHE_REDIS_PORT': 6379,
    'CACHE_REDIS_DB': 1,
    'CACHE_REDIS_URL': 'redis://superset_cache:6379/1',
}

# Session management using Redis
SESSION_COOKIE_SECURE = True
SESSION_COOKIE_HTTPONLY = True
SESSION_TYPE = 'redis'
SESSION_REDIS = 'redis://superset_cache:6379/0'
