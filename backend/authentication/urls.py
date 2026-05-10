from django.urls import path
from . import views

urlpatterns = [
    path('auth/login/', views.login, name='login'),
    path('auth/demo-data/', views.register_demo_data, name='demo-data'),
]