from rest_framework import generics, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError
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


class LogoutView(APIView):
    """
    Blacklists the refresh token, logging the user out.
    Expects: {"refresh": "<refresh_token>"}
    """
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        refresh_token = request.data.get('refresh')
        if not refresh_token:
            return Response(
                {'detail': 'Refresh token is required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        try:
            token = RefreshToken(refresh_token)
            token.blacklist()
        except TokenError:
            return Response(
                {'detail': 'Invalid or expired token.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        return Response(status=status.HTTP_205_RESET_CONTENT)