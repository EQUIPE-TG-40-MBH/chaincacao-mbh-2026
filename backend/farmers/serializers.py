from rest_framework import serializers
from .models import Farmer, Cooperative


class CooperativeSerializer(serializers.ModelSerializer):
    farmers_count = serializers.SerializerMethodField()

    class Meta:
        model = Cooperative
        fields = [
            'id', 'cooperative_id', 'name', 'region',
            'contact_email', 'contact_phone',
            'farmers_count', 'created_at'
        ]

    def get_farmers_count(self, obj):
        return obj.farmers.count()


class FarmerSerializer(serializers.ModelSerializer):
    cooperative_name = serializers.CharField(
        source='cooperative.name', read_only=True
    )
    full_name = serializers.CharField(read_only=True)
    gps_coordinates = serializers.CharField(read_only=True)
    lots_count = serializers.SerializerMethodField()

    class Meta:
        model = Farmer
        fields = [
            'id', 'farmer_id', 'first_name', 'last_name',
            'full_name', 'phone', 'cooperative', 'cooperative_name',
            'gps_latitude', 'gps_longitude', 'gps_coordinates',
            'region', 'village', 'language', 'qr_code',
            'lots_count', 'is_active', 'created_at'
        ]
        read_only_fields = ['farmer_id', 'qr_code', 'created_at']

    def get_lots_count(self, obj):
        return obj.lots.count()