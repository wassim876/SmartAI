from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    """
    Custom User model for the SmartAI application
    """
    # You can add custom fields here if needed
    # Example:
    # phone_number = models.CharField(max_length=15, blank=True, null=True)
    # profile_picture = models.ImageField(upload_to='profiles/', blank=True, null=True)
    
    def __str__(self):
        return self.username
    
    class Meta:
        db_table = 'users'  # Optional: specify table name