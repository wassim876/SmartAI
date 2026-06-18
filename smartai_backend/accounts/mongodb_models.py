# accounts/mongodb_models.py
from .mongodb_connection import mongodb_db
from django.utils import timezone
from bson import ObjectId


class MongoDBUser:
    """MongoDB User document operations"""
    
    collection_name = 'users'
    
    @classmethod
    def get_collection(cls):
        if mongodb_db is None:
            raise Exception("MongoDB connection not established")
        return mongodb_db[cls.collection_name]
    
    @classmethod
    def create(cls, data):
        collection = cls.get_collection()
        now = timezone.now()
        data['created_at'] = now
        data['updated_at'] = now
        result = collection.insert_one(data)
        data['_id'] = result.inserted_id
        return data
    
    @classmethod
    def find_one(cls, query):
        collection = cls.get_collection()
        return collection.find_one(query)
    
    @classmethod
    def find(cls, query=None, sort=None, limit=None, skip=None):
        collection = cls.get_collection()
        cursor = collection.find(query or {})
        if sort:
            cursor = cursor.sort(sort)
        if skip:
            cursor = cursor.skip(skip)
        if limit:
            cursor = cursor.limit(limit)
        return list(cursor)
    
    @classmethod
    def update(cls, query, data):
        collection = cls.get_collection()
        data['updated_at'] = timezone.now()
        return collection.update_one(query, {'$set': data})
    
    @classmethod
    def delete(cls, query):
        collection = cls.get_collection()
        return collection.delete_one(query)
    
    @classmethod
    def count(cls, query=None):
        collection = cls.get_collection()
        return collection.count_documents(query or {})
    
    @classmethod
    def to_dict(cls, user_doc):
        if user_doc is None:
            return None
        user_doc['id'] = str(user_doc['_id'])
        del user_doc['_id']
        return user_doc
    
    @classmethod
    def get_user_by_username_or_email(cls, identifier):
        collection = cls.get_collection()
        user = collection.find_one({
            '$or': [
                {'username': {'$regex': f'^{identifier}$', '$options': 'i'}},
                {'email': {'$regex': f'^{identifier}$', '$options': 'i'}}
            ]
        })
        return user


class ChatMessage:
    """Chat messages collection"""
    
    collection_name = 'chat_messages'
    
    @classmethod
    def get_collection(cls):
        if mongodb_db is None:
            raise Exception("MongoDB connection not established")
        return mongodb_db[cls.collection_name]
    
    @classmethod
    def create(cls, user_id, message, response, model='gpt-3.5-turbo'):
        collection = cls.get_collection()
        now = timezone.now()
        data = {
            'user_id': user_id,
            'message': message,
            'response': response,
            'model': model,
            'created_at': now,
            'updated_at': now
        }
        result = collection.insert_one(data)
        data['_id'] = result.inserted_id
        return data
    
    @classmethod
    def get_user_chats(cls, user_id, limit=50, skip=0):
        collection = cls.get_collection()
        cursor = collection.find({'user_id': user_id}).sort('created_at', -1).skip(skip).limit(limit)
        return list(cursor)
    
    @classmethod
    def delete_user_chats(cls, user_id):
        collection = cls.get_collection()
        return collection.delete_many({'user_id': user_id})


class ImageAnalysis:
    """Image analysis collection"""
    
    collection_name = 'image_analyses'
    
    @classmethod
    def get_collection(cls):
        if mongodb_db is None:
            raise Exception("MongoDB connection not established")
        return mongodb_db[cls.collection_name]
    
    @classmethod
    def create(cls, user_id, image_url, analysis_result, image_type='general'):
        collection = cls.get_collection()
        now = timezone.now()
        data = {
            'user_id': user_id,
            'image_url': image_url,
            'analysis_result': analysis_result,
            'image_type': image_type,
            'created_at': now,
            'updated_at': now
        }
        result = collection.insert_one(data)
        data['_id'] = result.inserted_id
        return data
    
    @classmethod
    def get_user_analyses(cls, user_id, limit=50, skip=0):
        collection = cls.get_collection()
        cursor = collection.find({'user_id': user_id}).sort('created_at', -1).skip(skip).limit(limit)
        return list(cursor)


class SpeechToText:
    """Speech to text collection"""
    
    collection_name = 'speech_transcriptions'
    
    @classmethod
    def get_collection(cls):
        if mongodb_db is None:
            raise Exception("MongoDB connection not established")
        return mongodb_db[cls.collection_name]
    
    @classmethod
    def create(cls, user_id, audio_url, transcription, duration=0):
        collection = cls.get_collection()
        now = timezone.now()
        data = {
            'user_id': user_id,
            'audio_url': audio_url,
            'transcription': transcription,
            'duration': duration,
            'created_at': now,
            'updated_at': now
        }
        result = collection.insert_one(data)
        data['_id'] = result.inserted_id
        return data
    
    @classmethod
    def get_user_transcriptions(cls, user_id, limit=50, skip=0):
        collection = cls.get_collection()
        cursor = collection.find({'user_id': user_id}).sort('created_at', -1).skip(skip).limit(limit)
        return list(cursor)


class Translation:
    """Translation collection"""
    
    collection_name = 'translations'
    
    @classmethod
    def get_collection(cls):
        if mongodb_db is None:
            raise Exception("MongoDB connection not established")
        return mongodb_db[cls.collection_name]
    
    @classmethod
    def create(cls, user_id, original_text, translated_text, source_lang, target_lang):
        collection = cls.get_collection()
        now = timezone.now()
        data = {
            'user_id': user_id,
            'original_text': original_text,
            'translated_text': translated_text,
            'source_lang': source_lang,
            'target_lang': target_lang,
            'created_at': now,
            'updated_at': now
        }
        result = collection.insert_one(data)
        data['_id'] = result.inserted_id
        return data
    
    @classmethod
    def get_user_translations(cls, user_id, limit=50, skip=0):
        collection = cls.get_collection()
        cursor = collection.find({'user_id': user_id}).sort('created_at', -1).skip(skip).limit(limit)
        return list(cursor)


class UserActivity:
    """User activity/audit log collection"""
    
    collection_name = 'user_activities'
    
    @classmethod
    def get_collection(cls):
        if mongodb_db is None:
            raise Exception("MongoDB connection not established")
        return mongodb_db[cls.collection_name]
    
    @classmethod
    def create(cls, user_id, action, details=None, ip_address=None):
        collection = cls.get_collection()
        data = {
            'user_id': user_id,
            'action': action,
            'details': details or {},
            'ip_address': ip_address,
            'created_at': timezone.now()
        }
        result = collection.insert_one(data)
        data['_id'] = result.inserted_id
        return data
    
    @classmethod
    def get_user_activities(cls, user_id, limit=50, skip=0):
        collection = cls.get_collection()
        cursor = collection.find({'user_id': user_id}).sort('created_at', -1).skip(skip).limit(limit)
        return list(cursor)