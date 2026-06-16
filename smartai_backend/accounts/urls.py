from django.urls import path
from .views import RegisterView, LogoutView, user_profile, list_users, increment_usage, reset_daily_usage

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('logout/', LogoutView.as_view(), name='logout'),
    
    # New User Profile and Usage endpoints
    path('user/profile/', user_profile, name='user_profile'),
    path('users/', list_users, name='list_users'),
    path('user/increment-usage/', increment_usage, name='increment_usage'),
    path('user/reset-daily-usage/', reset_daily_usage, name='reset_daily_usage'),
]