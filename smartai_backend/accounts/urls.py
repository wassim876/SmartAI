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
)

urlpatterns = [
    # Auth
    path('token/',          CustomLoginView.as_view(),  name='token_obtain_pair'),  # replaces SimpleJWT default
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
]