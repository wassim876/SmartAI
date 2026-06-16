from rest_framework import generics, permissions, status
from rest_framework.views import APIView
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError
from .serializers import RegisterSerializer
from .models import User

class RegisterView(generics.CreateAPIView):
    """
    API endpoint for user registration.
    """
    queryset = User.objects.all()
    permission_classes = (permissions.AllowAny,)
    serializer_class = RegisterSerializer


class LogoutView(APIView):
    """
    Blacklists the refresh token, logging the user out.
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


@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def user_profile(request):
    """
    Get current user profile data.
    """
    user = request.user
    
    data = {
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'first_name': user.first_name,
        'last_name': user.last_name,
        'name': f"{user.first_name} {user.last_name}".strip() or user.username,
        
        # Admin detection (Flutter uses this to route to Admin vs User dashboard)
        'is_staff': user.is_staff,
        'is_superuser': user.is_superuser,
        
        # Premium and usage tracking
        'is_premium': user.is_premium,
        'daily_messages_used': user.daily_messages_used,
        'daily_messages_limit': user.daily_messages_limit,
        'monthly_speech_minutes_used': user.monthly_speech_minutes_used,
        'monthly_speech_minutes_limit': user.monthly_speech_minutes_limit,
        'translation_chars_used': user.translation_chars_used,
        'translation_chars_limit': user.translation_chars_limit,
        
        'last_reset_date': user.last_reset_date,
        'profile_picture': request.build_absolute_uri(user.profile_picture.url) if user.profile_picture else None,
    }
    
    return Response(data, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def increment_usage(request):
    """
    Increment user usage counters when they use AI, Speech, or Translation.
    """
    user = request.user
    usage_type = request.data.get('type') # 'message', 'speech', 'translation'
    amount = request.data.get('amount', 1)
    
    if not usage_type:
        return Response({'detail': 'Usage type is required.'}, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        if usage_type == 'message':
            user.daily_messages_used += amount
        elif usage_type == 'speech':
            user.monthly_speech_minutes_used += amount
        elif usage_type == 'translation':
            user.translation_chars_used += amount
        else:
            return Response({'detail': 'Invalid usage type.'}, status=status.HTTP_400_BAD_REQUEST)
        
        user.save()
        return Response({'success': True}, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({'detail': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)