from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from django.contrib.auth import authenticate
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
        password = validated_data.pop('password')
        user = User.objects.create_user(**validated_data, password=password)
        return user


class LoginSerializer(serializers.Serializer):
    """
    Serializer for user login.
    Handles validation of username/email and password.
    """
    username_or_email = serializers.CharField(write_only=True)
    password = serializers.CharField(
        write_only=True,
        style={'input_type': 'password'}
    )

    def validate(self, data):
        username_or_email = data.get('username_or_email')
        password = data.get('password')

        if username_or_email and password:
            user = authenticate(request=self.context.get('request'),
                                username=username_or_email, password=password)
            if not user:
                raise serializers.ValidationError("Unable to log in with provided credentials.")
            data['user'] = user
            return data
        raise serializers.ValidationError("Must include 'username_or_email' and 'password'.")