from rest_framework import serializers
from .models import Lot, LotTransfer, Certificate
from farmers.serializers import FarmerSerializer, CooperativeSerializer


class LotTransferSerializer(serializers.ModelSerializer):
    class Meta:
        model = LotTransfer
        fields = [
            'id', 'from_actor', 'to_actor',
            'notes', 'blockchain_hash', 'transferred_at'
        ]


class LotSerializer(serializers.ModelSerializer):
    farmer_name = serializers.CharField(
        source='farmer.full_name', read_only=True
    )
    farmer_phone = serializers.CharField(
        source='farmer.phone', read_only=True
    )
    cooperative_name = serializers.CharField(
        source='cooperative.name', read_only=True
    )
    gps_coordinates = serializers.CharField(read_only=True)
    transfers = LotTransferSerializer(many=True, read_only=True)
    status_display = serializers.CharField(
        source='get_status_display', read_only=True
    )

    class Meta:
        model = Lot
        fields = [
            'id', 'lot_id', 'farmer', 'farmer_name', 'farmer_phone',
            'cooperative', 'cooperative_name',
            'weight_declared', 'weight_verified',
            'gps_latitude', 'gps_longitude', 'gps_coordinates',
            'culture_type', 'photo', 'status', 'status_display',
            'blockchain_hash', 'fraud_alert', 'fraud_details',
            'transfers', 'registered_at', 'updated_at'
        ]
        read_only_fields = [
            'lot_id', 'blockchain_hash',
            'fraud_alert', 'fraud_details',
            'registered_at', 'updated_at'
        ]


class LotPublicSerializer(serializers.ModelSerializer):
    farmer_name = serializers.CharField(
        source='farmer.full_name', read_only=True
    )
    cooperative_name = serializers.CharField(
        source='cooperative.name', read_only=True
    )
    gps_coordinates = serializers.CharField(read_only=True)
    transfers = LotTransferSerializer(many=True, read_only=True)
    region = serializers.CharField(
        source='farmer.region', read_only=True
    )

    class Meta:
        model = Lot
        fields = [
            'lot_id', 'farmer_name', 'cooperative_name',
            'weight_declared', 'weight_verified',
            'gps_coordinates', 'region',
            'culture_type', 'status',
            'blockchain_hash', 'fraud_alert',
            'transfers', 'registered_at'
        ]


class CertificateSerializer(serializers.ModelSerializer):
    lots_ids = serializers.SerializerMethodField()

    class Meta:
        model = Certificate
        fields = [
            'id', 'cert_id', 'lots', 'lots_ids',
            'cert_type', 'issued_by', 'total_weight',
            'blockchain_hash', 'pdf_file', 'issued_at'
        ]
        read_only_fields = ['cert_id', 'issued_at']

    def get_lots_ids(self, obj):
        return [lot.lot_id for lot in obj.lots.all()]