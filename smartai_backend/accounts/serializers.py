from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from .models import User # Assuming your custom User model is in accounts/models.py

class RegisterSerializer(serializers.ModelSerializer):
    """
    Serializer for user registration.
    Handles validation and creation of a new User instance.
    """
    password = serializers.CharField(
        write_only=True,
        required=True,
        validators=[validate_password],
        help_text="Required. 8 characters or more. Must contain letters and numbers."
    )

    class Meta:
        model = User
        fields = ('username', 'email', 'first_name', 'password')
        extra_kwargs = {
            'first_name': {'required': True, 'allow_blank': False},
            'email': {'required': True, 'allow_blank': False},
            'username': {'required': True, 'allow_blank': False}
        }

    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("A user with that email already exists.")
        return value

    def create(self, validated_data):
        user = User.objects.create(
            username=validated_data['username'],
            email=validated_data['email'],
            first_name=validated_data['first_name']
        )
        user.set_password(validated_data['password'])
        user.save()
        return user