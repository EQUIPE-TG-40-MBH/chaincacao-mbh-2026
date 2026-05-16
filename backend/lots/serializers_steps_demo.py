from rest_framework import serializers


class DemoWorkflowRunSerializer(serializers.Serializer):
    lot_id_1 = serializers.CharField(required=False, allow_blank=True, default="TGO-2026-00142")
    gps_latitude = serializers.FloatField(required=False, default=6.8925)
    gps_longitude = serializers.FloatField(required=False, default=0.6281)
    weight_declared = serializers.FloatField(required=False, default=65)

    # Qualité CCFCC
    rot_rate_percent = serializers.FloatField(required=False, default=1.8)
    humidity_percent = serializers.FloatField(required=False, default=7.5)
    sanitary_status = serializers.CharField(required=False, default="CONFORME")

    visual_observation = serializers.CharField(required=False, default="quelques fèves plates")

    # Fusion
    base_parent_lot_id_for_fus1 = serializers.CharField(required=False, default="TGO-2026-00142")
    # Le backend va créer/chercher 4 autres lots parents si besoin

