from django.urls import path
from . import views

urlpatterns = [
    path('cooperatives/', views.CooperativeListView.as_view(), name='cooperative-list'),
    path('cooperatives/<int:pk>/', views.CooperativeDetailView.as_view(), name='cooperative-detail'),
    path('cooperatives/<str:cooperative_id>/dashboard/', views.cooperative_dashboard, name='cooperative-dashboard'),
    path('cooperatives/<str:cooperative_id>/profile/', views.cooperative_profile, name='cooperative-profile'),
    path('farmers/', views.FarmerListView.as_view(), name='farmer-list'),
    path('farmers/<int:pk>/', views.FarmerDetailView.as_view(), name='farmer-detail'),
    path('farmers/qr/<str:farmer_id>/', views.farmer_by_qr, name='farmer-by-qr'),
    path('farmers/delete/<str:farmer_id>/', views.delete_farmer, name='delete-farmer'),
    path('farmers/purchase/', views.purchase_from_farmer, name='purchase-from-farmer'),
]