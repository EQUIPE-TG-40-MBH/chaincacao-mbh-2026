from rest_framework import generics, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from .models import Farmer, Cooperative
from .serializers import FarmerSerializer, CooperativeSerializer


class CooperativeListView(generics.ListCreateAPIView):
    queryset = Cooperative.objects.all()
    serializer_class = CooperativeSerializer
    permission_classes = [IsAuthenticated]


class CooperativeDetailView(generics.RetrieveUpdateAPIView):
    queryset = Cooperative.objects.all()
    serializer_class = CooperativeSerializer
    permission_classes = [IsAuthenticated]


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def cooperative_dashboard(request, cooperative_id):
    try:
        cooperative = Cooperative.objects.get(
            cooperative_id=cooperative_id
        )
    except Cooperative.DoesNotExist:
        return Response(
            {'error': 'Coopérative non trouvée'},
            status=status.HTTP_404_NOT_FOUND
        )

    from lots.models import Lot
    from django.utils import timezone
    today = timezone.now().date()

    lots_today = Lot.objects.filter(
        cooperative=cooperative,
        registered_at__date=today
    )

    total_kg = sum(
        l.weight_declared for l in lots_today
    )
    fraud_alerts = lots_today.filter(fraud_alert=True).count()
    pending = lots_today.filter(status='REGISTERED').count()
    validated = lots_today.filter(status='VALIDATED').count()

    return Response({
        'cooperative': CooperativeSerializer(cooperative).data,
        'stats': {
            'lots_today': lots_today.count(),
            'total_kg_today': total_kg,
            'fraud_alerts': fraud_alerts,
            'pending': pending,
            'validated': validated,
            'farmers_count': cooperative.farmers.count(),
        }
    })


class FarmerListView(generics.ListCreateAPIView):
    serializer_class = FarmerSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Farmer.objects.all()
        cooperative_id = self.request.query_params.get('cooperative')
        if cooperative_id:
            queryset = queryset.filter(
                cooperative__cooperative_id=cooperative_id
            )
        return queryset


class FarmerDetailView(generics.RetrieveUpdateAPIView):
    queryset = Farmer.objects.all()
    serializer_class = FarmerSerializer
    permission_classes = [IsAuthenticated]


@api_view(['GET'])
@permission_classes([AllowAny])
def farmer_by_qr(request, farmer_id):
    try:
        farmer = Farmer.objects.get(farmer_id=farmer_id)
        return Response(FarmerSerializer(farmer).data)
    except Farmer.DoesNotExist:
        return Response(
            {'error': 'Agriculteur non trouvé'},
            status=status.HTTP_404_NOT_FOUND
        )