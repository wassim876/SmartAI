from rest_framework import generics, permissions
from .serializers import RegisterSerializer
from .models import User # Ensure your custom User model is defined here

class RegisterView(generics.CreateAPIView):
    """
    API endpoint for user registration.
    Allows new users to create an account.
    """
    queryset = User.objects.all()
    permission_classes = (permissions.AllowAny,) # Allow unauthenticated users to register
    serializer_class = RegisterSerializer