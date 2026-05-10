from django.urls import path
from . import views

urlpatterns = [
    path('lots/', views.LotListView.as_view(), name='lot-list'),
    path('lots/<str:lot_id>/', views.LotDetailView.as_view(), name='lot-detail'),
    path('lots/public/<str:lot_id>/', views.lot_public, name='lot-public'),
    path('lots/<str:lot_id>/transfer/', views.lot_transfer, name='lot-transfer'),
    path('lots/<str:lot_id>/certificate/', views.attach_certificate, name='lot-certificate'),
    path('certificates/eudr/', views.generate_eudr_certificate, name='generate-eudr'),
]