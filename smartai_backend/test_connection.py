# test_connection.py
import os
from pymongo import MongoClient
from dotenv import load_dotenv

load_dotenv()

MONGODB_URI = os.getenv('MONGODB_URI')
MONGODB_DB_NAME = os.getenv('MONGODB_DB_NAME', 'smartai_db')

print("🔗 Connecting to MongoDB Atlas...")

try:
    # Add timeout settings to avoid hanging
    client = MongoClient(
        MONGODB_URI,
        serverSelectionTimeoutMS=10000,  # 10 seconds timeout
        connectTimeoutMS=10000,
        socketTimeoutMS=10000
    )
    
    db = client[MONGODB_DB_NAME]
    db.command('ping')
    
    print("✅ Successfully connected to MongoDB Atlas!")
    print(f"📊 Database: {MONGODB_DB_NAME}")
    
except Exception as e:
    print(f"❌ Connection failed: {e}")