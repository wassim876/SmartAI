from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils import timezone

class User(AbstractUser):
    """
    Custom User model for the SmartAI application
    """
    email = models.EmailField(unique=True)

    # Premium status
    is_premium = models.BooleanField(default=False)
    
    # Usage tracking
    daily_messages_used = models.IntegerField(default=0)
    daily_messages_limit = models.IntegerField(default=50)
    
    monthly_speech_minutes_used = models.IntegerField(default=0)
    monthly_speech_minutes_limit = models.IntegerField(default=10)
    
    translation_chars_used = models.IntegerField(default=0)
    translation_chars_limit = models.IntegerField(default=1000)
    
    # Reset tracking
    last_reset_date = models.DateTimeField(default=timezone.now)
    
    # Profile picture
    profile_picture = models.ImageField(upload_to='profiles/', blank=True, null=True)

    def __str__(self):
        return self.username
    
    class Meta:
        db_table = 'users'