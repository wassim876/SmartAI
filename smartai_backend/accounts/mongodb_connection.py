# accounts/mongodb_connection.py
import os
import pymongo

# Get MongoDB connection settings
MONGODB_URI = os.getenv('MONGODB_URI', 'mongodb://localhost:27017/')
MONGODB_DB_NAME = os.getenv('MONGODB_DB_NAME', 'smartai_db')

# Create MongoDB client
try:
    mongodb_client = pymongo.MongoClient(
        MONGODB_URI,
        serverSelectionTimeoutMS=10000,
        connectTimeoutMS=10000,
        socketTimeoutMS=10000
    )
    mongodb_db = mongodb_client[MONGODB_DB_NAME]
    mongodb_db.command('ping')
    print(f"✅ MongoDB Connection established: {MONGODB_DB_NAME}")
except Exception as e:
    print(f"❌ MongoDB Connection Error: {e}")
    mongodb_client = None
    mongodb_db = None