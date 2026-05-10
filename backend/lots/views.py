from rest_framework import generics, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from .models import Lot, LotTransfer, Certificate
from .serializers import (
    LotSerializer, LotPublicSerializer,
    LotTransferSerializer, CertificateSerializer
)
import hashlib
import time


def generate_demo_hash(lot_id):
    data = f"{lot_id}{time.time()}"
    return "0x" + hashlib.sha256(data.encode()).hexdigest()


class LotListView(generics.ListCreateAPIView):
    serializer_class = LotSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Lot.objects.all().order_by('-registered_at')
        cooperative_id = self.request.query_params.get('cooperative')
        status_filter = self.request.query_params.get('status')
        farmer_id = self.request.query_params.get('farmer')

        if cooperative_id:
            queryset = queryset.filter(
                cooperative__cooperative_id=cooperative_id
            )
        if status_filter:
            queryset = queryset.filter(status=status_filter)
        if farmer_id:
            queryset = queryset.filter(
                farmer__farmer_id=farmer_id
            )
        return queryset

    def perform_create(self, serializer):
        lot = serializer.save()
        lot.blockchain_hash = generate_demo_hash(lot.lot_id)
        lot.save()

        LotTransfer.objects.create(
            lot=lot,
            from_actor='SYSTEM',
            to_actor=lot.farmer.full_name,
            notes='Enregistrement initial du lot',
            blockchain_hash=lot.blockchain_hash
        )


class LotDetailView(generics.RetrieveUpdateAPIView):
    queryset = Lot.objects.all()
    serializer_class = LotSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = 'lot_id'


@api_view(['GET'])
@permission_classes([AllowAny])
def lot_public(request, lot_id):
    try:
        lot = Lot.objects.get(lot_id=lot_id)
        return Response(LotPublicSerializer(lot).data)
    except Lot.DoesNotExist:
        return Response(
            {'error': 'Lot non trouvé'},
            status=status.HTTP_404_NOT_FOUND
        )


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def lot_transfer(request, lot_id):
    try:
        lot = Lot.objects.get(lot_id=lot_id)
    except Lot.DoesNotExist:
        return Response(
            {'error': 'Lot non trouvé'},
            status=status.HTTP_404_NOT_FOUND
        )

    weight_verified = request.data.get('weight_verified')
    from_actor = request.data.get('from_actor', 'FARMER')
    to_actor = request.data.get('to_actor', 'COOPERATIVE')
    notes = request.data.get('notes', '')

    if weight_verified:
        lot.weight_verified = float(weight_verified)
        lot.check_fraud()

    blockchain_hash = generate_demo_hash(lot_id)

    LotTransfer.objects.create(
        lot=lot,
        from_actor=from_actor,
        to_actor=to_actor,
        notes=notes,
        blockchain_hash=blockchain_hash
    )

    lot.blockchain_hash = blockchain_hash
    if not lot.fraud_alert:
        lot.status = 'IN_TRANSFER'
    lot.save()

    return Response({
        'message': 'Transfert enregistré avec succès',
        'lot_id': lot.lot_id,
        'status': lot.status,
        'fraud_alert': lot.fraud_alert,
        'fraud_details': lot.fraud_details,
        'blockchain_hash': blockchain_hash,
    })


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def generate_eudr_certificate(request):
    lot_ids = request.data.get('lot_ids', [])
    if not lot_ids:
        return Response(
            {'error': 'Aucun lot sélectionné'},
            status=status.HTTP_400_BAD_REQUEST
        )

    lots = Lot.objects.filter(lot_id__in=lot_ids)
    if not lots.exists():
        return Response(
            {'error': 'Lots non trouvés'},
            status=status.HTTP_404_NOT_FOUND
        )

    total_weight = sum(
        l.weight_verified or l.weight_declared for l in lots
    )
    blockchain_hash = generate_demo_hash("EUDR")

    certificate = Certificate.objects.create(
        cert_type='EUDR',
        issued_by='ChainCacao Export SARL',
        total_weight=total_weight,
        blockchain_hash=blockchain_hash
    )
    certificate.lots.set(lots)

    for lot in lots:
        lot.status = 'EXPORTED'
        lot.save()
        LotTransfer.objects.create(
            lot=lot,
            from_actor='EXPORTATEUR',
            to_actor='IMPORTATEUR_EU',
            notes=f'Inclus dans certificat EUDR {certificate.cert_id}',
            blockchain_hash=blockchain_hash
        )

    return Response({
        'message': 'Certificat EUDR généré avec succès',
        'certificate': CertificateSerializer(certificate).data,
    }, status=status.HTTP_201_CREATED)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def attach_certificate(request, lot_id):
    try:
        lot = Lot.objects.get(lot_id=lot_id)
    except Lot.DoesNotExist:
        return Response(
            {'error': 'Lot non trouvé'},
            status=status.HTTP_404_NOT_FOUND
        )

    cert_type = request.data.get('cert_type', 'EUDR')
    blockchain_hash = generate_demo_hash(lot_id + cert_type)

    certificate = Certificate.objects.create(
        cert_type=cert_type,
        issued_by=request.data.get('issued_by', 'ChainCacao'),
        total_weight=lot.weight_verified or lot.weight_declared,
        blockchain_hash=blockchain_hash
    )
    certificate.lots.add(lot)
    lot.status = 'CERTIFIED'
    lot.save()

    return Response({
        'message': 'Certificat attaché avec succès',
        'certificate': CertificateSerializer(certificate).data,
    }, status=status.HTTP_201_CREATED)