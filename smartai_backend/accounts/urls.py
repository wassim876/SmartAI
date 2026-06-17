# accounts/urls.py
from django.urls import path
from .views import (
    RegisterView, 
    LogoutView, 
    user_profile, 
    list_users, 
    increment_usage, 
    reset_daily_usage,
    update_user,           # NEW
    delete_user,           # NEW
    toggle_user_status,    # NEW
    toggle_user_premium,   # NEW
)

urlpatterns = [
    # Auth endpoints
    path('register/', RegisterView.as_view(), name='register'),
    path('logout/', LogoutView.as_view(), name='logout'),
    
    # User Profile and Usage
    path('user/profile/', user_profile, name='user_profile'),
    path('user/increment-usage/', increment_usage, name='increment_usage'),
    path('user/reset-daily-usage/', reset_daily_usage, name='reset_daily_usage'),
    
    # Admin User Management (NEW)
    path('users/', list_users, name='list_users'),
    path('users/<int:user_id>/', update_user, name='update_user'),
    path('users/<int:user_id>/delete/', delete_user, name='delete_user'),
    path('users/<int:user_id>/toggle-status/', toggle_user_status, name='toggle_user_status'),
    path('users/<int:user_id>/toggle-premium/', toggle_user_premium, name='toggle_user_premium'),
]