from django.utils import timezone
from django.contrib.auth import authenticate
from rest_framework import generics, permissions, status
from rest_framework.views import APIView
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError
from .serializers import RegisterSerializer, UserListSerializer
from .models import User
from .mongodb_models import (
    ChatMessage,
    ImageAnalysis,
    SpeechToText,
    Translation,
    UserActivity
)
from bson import ObjectId


# ── Custom login — accepts email OR username ──────────────────────
class CustomLoginView(APIView):
    """
    POST /api/login/
    Accepts { username_or_email, password }
    Returns { access, refresh, user }
    """
    permission_classes = (permissions.AllowAny,)

    def post(self, request):
        identifier = request.data.get('username', '') or request.data.get('username_or_email', '')
        password   = request.data.get('password', '')

        if not identifier or not password:
            return Response(
                {'detail': 'Username/email and password are required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Try username first, then email
        user = authenticate(request=request, username=identifier, password=password)

        if user is None:
            # Try finding by email and authenticating with the actual username
            try:
                db_user = User.objects.get(email__iexact=identifier)
                user = authenticate(request=request, username=db_user.username, password=password)
            except User.DoesNotExist:
                pass

        if user is None:
            return Response(
                {'detail': 'No active account found with the given credentials.'},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        if not user.is_active:
            return Response(
                {'detail': 'This account has been disabled.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        refresh = RefreshToken.for_user(user)
        return Response({
            'access':  str(refresh.access_token),
            'refresh': str(refresh),
        }, status=status.HTTP_200_OK)


# ── Register — returns tokens directly ───────────────────────────
class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (permissions.AllowAny,)
    serializer_class = RegisterSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        refresh = RefreshToken.for_user(user)
        return Response({
            'access':  str(refresh.access_token),
            'refresh': str(refresh),
        }, status=status.HTTP_201_CREATED)


# ── Logout ────────────────────────────────────────────────────────
class LogoutView(APIView):
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


# ── User profile ──────────────────────────────────────────────────
@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def user_profile(request):
    user = request.user
    data = {
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'first_name': user.first_name,
        'last_name': user.last_name,
        'name': f"{user.first_name} {user.last_name}".strip() or user.username,
        'is_staff': user.is_staff,
        'is_superuser': user.is_superuser,
        'is_active': user.is_active,
        'date_joined': user.date_joined,
        'is_premium': getattr(user, 'is_premium', False),
        'daily_messages_used': getattr(user, 'daily_messages_used', 0),
        'daily_messages_limit': getattr(user, 'daily_messages_limit', 50),
        'monthly_speech_minutes_used': getattr(user, 'monthly_speech_minutes_used', 0),
        'monthly_speech_minutes_limit': getattr(user, 'monthly_speech_minutes_limit', 10),
        'translation_chars_used': getattr(user, 'translation_chars_used', 0),
        'translation_chars_limit': getattr(user, 'translation_chars_limit', 1000),
        'last_reset_date': getattr(user, 'last_reset_date', timezone.now()),
        'profile_picture': request.build_absolute_uri(user.profile_picture.url)
            if hasattr(user, 'profile_picture') and user.profile_picture else None,
    }
    return Response(data, status=status.HTTP_200_OK)


# ============================================
# NEW DATA STORAGE ENDPOINTS
# ============================================

@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def save_chat_message(request):
    """Save a chat message and response"""
    try:
        user = request.user
        message = request.data.get('message')
        response = request.data.get('response')
        model = request.data.get('model', 'gpt-3.5-turbo')
        
        if not message or not response:
            return Response({
                'detail': 'Message and response are required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Save to MongoDB
        chat = ChatMessage.create(
            user_id=user.id,
            message=message,
            response=response,
            model=model
        )
        
        # Log activity
        UserActivity.create(
            user_id=user.id,
            action='chat_message',
            details={'message': message[:100], 'model': model}
        )
        
        return Response({
            'success': True,
            'data': {
                'id': str(chat['_id']),
                'message': chat['message'],
                'response': chat['response'],
                'created_at': chat['created_at']
            }
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        return Response({
            'detail': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def get_chat_history(request):
    """Get user's chat history"""
    try:
        limit = int(request.query_params.get('limit', 50))
        skip = int(request.query_params.get('skip', 0))
        
        chats = ChatMessage.get_user_chats(request.user.id, limit=limit, skip=skip)
        
        # Convert ObjectId to string
        for chat in chats:
            chat['_id'] = str(chat['_id'])
        
        return Response({
            'success': True,
            'data': chats,
            'count': len(chats)
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'detail': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def save_image_analysis(request):
    """Save image analysis result"""
    try:
        user = request.user
        image_url = request.data.get('image_url')
        analysis_result = request.data.get('analysis_result')
        image_type = request.data.get('image_type', 'general')
        
        if not image_url or not analysis_result:
            return Response({
                'detail': 'Image URL and analysis result are required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Save to MongoDB
        analysis = ImageAnalysis.create(
            user_id=user.id,
            image_url=image_url,
            analysis_result=analysis_result,
            image_type=image_type
        )
        
        # Log activity
        UserActivity.create(
            user_id=user.id,
            action='image_analysis',
            details={'image_type': image_type}
        )
        
        return Response({
            'success': True,
            'data': {
                'id': str(analysis['_id']),
                'image_url': analysis['image_url'],
                'analysis_result': analysis['analysis_result'],
                'created_at': analysis['created_at']
            }
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        return Response({
            'detail': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def save_speech_transcription(request):
    """Save speech to text transcription"""
    try:
        user = request.user
        audio_url = request.data.get('audio_url')
        transcription = request.data.get('transcription')
        duration = request.data.get('duration', 0)
        
        if not audio_url or not transcription:
            return Response({
                'detail': 'Audio URL and transcription are required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Save to MongoDB
        speech = SpeechToText.create(
            user_id=user.id,
            audio_url=audio_url,
            transcription=transcription,
            duration=duration
        )
        
        # Log activity
        UserActivity.create(
            user_id=user.id,
            action='speech_to_text',
            details={'duration': duration}
        )
        
        return Response({
            'success': True,
            'data': {
                'id': str(speech['_id']),
                'transcription': speech['transcription'],
                'duration': speech['duration'],
                'created_at': speech['created_at']
            }
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        return Response({
            'detail': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def save_translation(request):
    """Save translation"""
    try:
        user = request.user
        original_text = request.data.get('original_text')
        translated_text = request.data.get('translated_text')
        source_lang = request.data.get('source_lang', 'auto')
        target_lang = request.data.get('target_lang')
        
        if not original_text or not translated_text or not target_lang:
            return Response({
                'detail': 'Original text, translated text, and target language are required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Save to MongoDB
        translation = Translation.create(
            user_id=user.id,
            original_text=original_text,
            translated_text=translated_text,
            source_lang=source_lang,
            target_lang=target_lang
        )
        
        # Log activity
        UserActivity.create(
            user_id=user.id,
            action='translation',
            details={'source': source_lang, 'target': target_lang}
        )
        
        return Response({
            'success': True,
            'data': {
                'id': str(translation['_id']),
                'original_text': translation['original_text'],
                'translated_text': translation['translated_text'],
                'created_at': translation['created_at']
            }
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        return Response({
            'detail': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def get_user_activities(request):
    """Get user's activity log"""
    try:
        limit = int(request.query_params.get('limit', 50))
        skip = int(request.query_params.get('skip', 0))
        
        activities = UserActivity.get_user_activities(
            request.user.id,
            limit=limit,
            skip=skip
        )
        
        # Convert ObjectId to string
        for activity in activities:
            activity['_id'] = str(activity['_id'])
        
        return Response({
            'success': True,
            'data': activities,
            'count': len(activities)
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'detail': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ── Usage tracking ────────────────────────────────────────────────
@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def increment_usage(request):
    user = request.user
    usage_type = request.data.get('type', 'message')
    amount = int(request.data.get('amount', 1))

    if usage_type == 'message':
        user.daily_messages_used = min(
            user.daily_messages_used + amount,
            user.daily_messages_limit
        )
    elif usage_type == 'speech':
        user.monthly_speech_minutes_used += amount
    elif usage_type == 'translation':
        user.translation_chars_used += amount

    user.save()
    return Response({'success': True}, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def reset_daily_usage(request):
    user = request.user
    user.daily_messages_used = 0
    user.translation_chars_used = 0
    user.last_reset_date = timezone.now()
    user.save()
    return Response({'success': True}, status=status.HTTP_200_OK)


# ── Admin user management ─────────────────────────────────────────
@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def list_users(request):
    if not (request.user.is_staff or request.user.is_superuser):
        return Response({'detail': 'Permission denied.'}, status=status.HTTP_403_FORBIDDEN)
    users = User.objects.all().order_by('-date_joined')
    serializer = UserListSerializer(users, many=True)
    return Response({'success': True, 'data': serializer.data}, status=status.HTTP_200_OK)


@api_view(['PUT', 'PATCH'])
@permission_classes([permissions.IsAuthenticated])
def update_user(request, user_id):
    if not (request.user.is_staff or request.user.is_superuser):
        return Response({'detail': 'Permission denied.'}, status=status.HTTP_403_FORBIDDEN)
    try:
        user = User.objects.get(id=user_id)
    except User.DoesNotExist:
        return Response({'detail': 'User not found.'}, status=status.HTTP_404_NOT_FOUND)

    for field in ['first_name', 'last_name', 'email', 'is_premium', 'daily_messages_limit',
                  'is_active', 'is_staff']:
        if field in request.data:
            setattr(user, field, request.data[field])
    user.save()
    serializer = UserListSerializer(user)
    return Response({'success': True, 'data': serializer.data}, status=status.HTTP_200_OK)


@api_view(['DELETE'])
@permission_classes([permissions.IsAuthenticated])
def delete_user(request, user_id):
    if not (request.user.is_staff or request.user.is_superuser):
        return Response({'detail': 'Permission denied.'}, status=status.HTTP_403_FORBIDDEN)
    try:
        user = User.objects.get(id=user_id)
        user.delete()
        return Response({'success': True}, status=status.HTTP_200_OK)
    except User.DoesNotExist:
        return Response({'detail': 'User not found.'}, status=status.HTTP_404_NOT_FOUND)


@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def toggle_user_status(request, user_id):
    if not (request.user.is_staff or request.user.is_superuser):
        return Response({'detail': 'Permission denied.'}, status=status.HTTP_403_FORBIDDEN)
    try:
        user = User.objects.get(id=user_id)
        user.is_active = not user.is_active
        user.save()
        return Response({'success': True, 'is_active': user.is_active}, status=status.HTTP_200_OK)
    except User.DoesNotExist:
        return Response({'detail': 'User not found.'}, status=status.HTTP_404_NOT_FOUND)


@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def toggle_user_premium(request, user_id):
    if not (request.user.is_staff or request.user.is_superuser):
        return Response({'detail': 'Permission denied.'}, status=status.HTTP_403_FORBIDDEN)
    try:
        user = User.objects.get(id=user_id)
        user.is_premium = not user.is_premium
        user.save()
        return Response({'success': True, 'is_premium': user.is_premium}, status=status.HTTP_200_OK)
    except User.DoesNotExist:
        return Response({'detail': 'User not found.'}, status=status.HTTP_404_NOT_FOUND)