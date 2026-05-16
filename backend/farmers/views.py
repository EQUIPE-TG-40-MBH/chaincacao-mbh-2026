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
        cooperative = Cooperative.objects.get(cooperative_id=cooperative_id)
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

    total_kg = sum(l.weight_declared for l in lots_today)
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
    """Endpoint utilisé par l'agriculteur après scan du QR.
    Le QR contient farmer_id. Répond avec les infos nécessaires côté mobile.
    """
    try:
        farmer = Farmer.objects.get(farmer_id=farmer_id)
        return Response({
            'farmer': FarmerSerializer(farmer).data,
            'auth': {
                'ok': True,
                'message': 'QR valide'
            }
        })
    except Farmer.DoesNotExist:
        return Response(
            {
                'auth': {
                    'ok': False,
                    'message': 'QR invalide'
                },
                'error': 'Agriculteur non trouvé'
            },
            status=status.HTTP_404_NOT_FOUND
        )



@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_farmer(request, farmer_id):
    try:
        farmer = Farmer.objects.get(farmer_id=farmer_id)
        name = farmer.full_name
        farmer.delete()
        return Response(
            {'message': f'Agriculteur {name} supprimé avec succès'},
            status=status.HTTP_200_OK
        )
    except Farmer.DoesNotExist:
        return Response(
            {'error': 'Agriculteur non trouvé'},
            status=status.HTTP_404_NOT_FOUND
        )


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def purchase_from_farmer(request):
    from lots.models import Lot, LotTransfer
    import hashlib
    import time

    farmer_id = request.data.get('farmer_id')
    weight = request.data.get('weight')
    culture_type = request.data.get('culture_type', 'cacao')
    price = request.data.get('price', 0)
    gps_latitude = request.data.get('gps_latitude')
    gps_longitude = request.data.get('gps_longitude')

    try:
        farmer = Farmer.objects.get(farmer_id=farmer_id)
    except Farmer.DoesNotExist:
        return Response(
            {'error': 'Agriculteur non trouvé'},
            status=status.HTTP_404_NOT_FOUND
        )

    from django.utils import timezone
    year = timezone.now().year
    count = Lot.objects.count() + 1
    lot_id = f"TG-{year}-{count:04d}"

    data = f"{lot_id}{time.time()}"
    blockchain_hash = "0x" + hashlib.sha256(data.encode()).hexdigest()

    lot = Lot.objects.create(
        lot_id=lot_id,
        farmer=farmer,
        cooperative=farmer.cooperative,
        weight_declared=weight,
        weight_verified=weight,
        culture_type=culture_type,
        gps_latitude=gps_latitude or farmer.gps_latitude,
        gps_longitude=gps_longitude or farmer.gps_longitude,
        status='VALIDATED',
        blockchain_hash=blockchain_hash,
    )

    LotTransfer.objects.create(
        lot=lot,
        from_actor=farmer.full_name,
        to_actor=farmer.cooperative.name,
        notes=f'Achat coopérative — Prix : {price} FCFA',
        blockchain_hash=blockchain_hash,
    )

    return Response({
        'message': 'Achat enregistré avec succès',
        'lot_id': lot.lot_id,
        'farmer': farmer.full_name,
        'cooperative': farmer.cooperative.name,
        'weight': weight,
        'price': price,
        'culture_type': culture_type,
        'blockchain_hash': blockchain_hash,
        'qr_url': f'/api/lots/public/{lot.lot_id}/',
    }, status=status.HTTP_201_CREATED)

@api_view(['GET', 'PATCH'])
@permission_classes([IsAuthenticated])
def cooperative_profile(request, cooperative_id):
    try:
        cooperative = Cooperative.objects.get(
            cooperative_id=cooperative_id
        )
    except Cooperative.DoesNotExist:
        return Response(
            {'error': 'Cooperative introuvable'},
            status=status.HTTP_404_NOT_FOUND
        )
    if request.method == 'GET':
        return Response(CooperativeSerializer(cooperative).data)
    if request.method == 'PATCH':
        name = request.data.get('name', cooperative.name)
        region = request.data.get('region', cooperative.region)
        contact_email = request.data.get(
            'contact_email', cooperative.contact_email
        )
        contact_phone = request.data.get(
            'contact_phone', cooperative.contact_phone
        )
        cooperative.name = name
        cooperative.region = region
        cooperative.contact_email = contact_email
        cooperative.contact_phone = contact_phone
        cooperative.save()
        return Response({
            'message': 'Profil mis a jour',
            'cooperative': CooperativeSerializer(cooperative).data,
        })