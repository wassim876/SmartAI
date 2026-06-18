# accounts/urls.py
from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (
    CustomLoginView,
    RegisterView,
    LogoutView,
    user_profile,
    list_users,
    increment_usage,
    reset_daily_usage,
    update_user,
    delete_user,
    toggle_user_status,
    toggle_user_premium,
    # NEW IMPORTS
    save_chat_message,
    get_chat_history,
    save_image_analysis,
    save_speech_transcription,
    save_translation,
    get_user_activities,
)

urlpatterns = [
    # Auth
    path('token/',          CustomLoginView.as_view(),  name='token_obtain_pair'),
    path('token/refresh/',  TokenRefreshView.as_view(), name='token_refresh'),
    path('register/',       RegisterView.as_view(),     name='register'),
    path('logout/',         LogoutView.as_view(),       name='logout'),

    # User
    path('user/profile/',           user_profile,      name='user_profile'),
    path('user/increment-usage/',   increment_usage,   name='increment_usage'),
    path('user/reset-daily-usage/', reset_daily_usage, name='reset_daily_usage'),

    # Admin user management
    path('users/',                          list_users,          name='list_users'),
    path('users/<int:user_id>/',            update_user,         name='update_user'),
    path('users/<int:user_id>/delete/',     delete_user,         name='delete_user'),
    path('users/<int:user_id>/toggle-status/',   toggle_user_status,   name='toggle_user_status'),
    path('users/<int:user_id>/toggle-premium/',  toggle_user_premium,  name='toggle_user_premium'),
    
    # ============================================
    # NEW DATA STORAGE ENDPOINTS
    # ============================================
    # Chat
    path('chat/save/', save_chat_message, name='save_chat_message'),
    path('chat/history/', get_chat_history, name='get_chat_history'),
    
    # Image Analysis
    path('image-analysis/save/', save_image_analysis, name='save_image_analysis'),
    
    # Speech to Text
    path('speech/save/', save_speech_transcription, name='save_speech_transcription'),
    
    # Translation
    path('translation/save/', save_translation, name='save_translation'),
    
    # Activities
    path('activities/', get_user_activities, name='get_user_activities'),
]