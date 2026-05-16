from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from django.utils import timezone
from django.db import transaction

from farmers.models import Farmer, Cooperative

from .models import Lot
from .chain_steps import build_tx_ref
from .quality_workflow import (
    QualityCheck,
    step_b001_create_lot,
    step_b002_receive_and_weigh,
    step_b003_quality_certify,
    step_b004_merge_to_fus1,
    step_b005_transport_to_exporter,
    step_b006_exporter_ready,
    step_b007_otr_customs_export,
    step_b008_importer_delivered,
)

from .actors import (
    ACTOR_FARMER,
    ACTOR_COOPERATIVE,
    ACTOR_CCFCC,
    ACTOR_EXPORTER,
    ACTOR_OTR,
    ACTOR_IMPORTER_EU,
)

from .serializers_steps_demo import DemoWorkflowRunSerializer


def _get_or_create_farmers_and_coop_for_demo():
    coop, _ = Cooperative.objects.get_or_create(
        cooperative_id="COOP-TG-001",
        defaults={
            "name": "Haho Cacao Union",
            "region": "Plateaux",
            "contact_email": "haho@chaincacao.tg",
            "contact_phone": "+22890000010",
        },
    )

    farmer, _ = Farmer.objects.get_or_create(
        phone="+22890000002",
        defaults={
            "first_name": "Kodjo",
            "last_name": "Mensah",
            "cooperative": coop,
            "gps_latitude": 6.8925,
            "gps_longitude": 0.6281,
            "region": "Plateaux",
            "village": "Kpalimé",
            "language": "fr",
        },
    )

    # Créons 4 autres lots parents (TGO-2026-00137..140) en respectant le modèle.
    parents = []
    parent_specs = [
        ("TGO-2026-00137", 60.0, 6.8900, 0.6489),
        ("TGO-2026-00138", 61.0, 6.8910, 0.6490),
        ("TGO-2026-00139", 62.0, 6.8920, 0.6500),
        ("TGO-2026-00140", 63.0, 6.8930, 0.6510),
    ]
    for i, (lot_id, w, lat, lon) in enumerate(parent_specs):
        # On associe tous les lots au même farmer pour simplifier le démo-run.
        # Si tu veux strictement 5 producteurs différents, on étendra ici.
        farmer_i, _ = Farmer.objects.get_or_create(
            phone=f"+2289000002{i+5}",
            defaults={
                "first_name": f"Farmer{i+1}",
                "last_name": "Demo",
                "cooperative": coop,
                "gps_latitude": lat,
                "gps_longitude": lon,
                "region": "Plateaux",
                "village": "Kpalimé",
                "language": "fr",
            },
        )
        # Le lot parent sera créé à travers le step_b001_create_lot dans la boucle.
        parents.append((lot_id, farmer_i, w, lat, lon))

    return coop, farmer, parents


@api_view(["POST"])
@permission_classes([IsAuthenticated])
@transaction.atomic
def run_demo_workflow(request):
    serializer = DemoWorkflowRunSerializer(data=request.data or {})
    serializer.is_valid(raise_exception=True)
    data = serializer.validated_data

    coop, farmer_kodjo, parents_specs = _get_or_create_farmers_and_coop_for_demo()

    # Étape 1
    lot = step_b001_create_lot(
        farmer=farmer_kodjo,
        cooperative=coop,
        gps_latitude=data["gps_latitude"],
        gps_longitude=data["gps_longitude"],
        weight_declared=data["weight_declared"],
        culture_type="cacao",
        photo=None,
        recent_treatments="Aucun pesticide",
        quality_observation="Bonne fermentation, légère odeur de fruits",
        lot_id=data["lot_id_1"],
        status="REGISTERED",
    )

    # Étape 2 (Coop)
    tx_b002 = step_b002_receive_and_weigh(
        lot=lot,
        cooperative_name=coop.name,
        weight_real=62.5,
        tx_ref=build_tx_ref("B002", 1),
        cooperative_actor=ACTOR_COOPERATIVE,
        farmer_actor=ACTOR_FARMER,
    )

    # Étape 3 (CCFCC)
    quality = QualityCheck(
        rot_rate_percent=1.8,
        humidity_percent=7.5,
        sanitary_status="CONFORME",
        visual_observation="quelques fèves plates",
    )
    tx_b003 = step_b003_quality_certify(
        lot=lot,
        quality=quality,
        tx_ref=build_tx_ref("B003", 1),
        ccfcc_actor=ACTOR_CCFCC,
    )

    # Étapes 4 : créer 4 parents + fusion en FUS1
    created_parent_lots = []
    for (parent_lot_id, farmer_i, w, lat, lon) in parents_specs:
        # 1) créer parent (déclaré)
        parent = step_b001_create_lot(
            farmer=farmer_i,
            cooperative=coop,
            gps_latitude=lat,
            gps_longitude=lon,
            weight_declared=w,
            culture_type="cacao",
            photo=None,
            recent_treatments="Aucun pesticide",
            quality_observation="Bonne fermentation",
            lot_id=parent_lot_id,
            status="REGISTERED",
        )
        # 2) recevoir/poids (on force une vérif légèrement différente)
        step_b002_receive_and_weigh(
            lot=parent,
            cooperative_name=coop.name,
            weight_real=w - 2.0,
            tx_ref=build_tx_ref("B002", 2 + len(created_parent_lots)),
            cooperative_actor=ACTOR_COOPERATIVE,
            farmer_actor=ACTOR_FARMER,
        )
        # 3) qualité conforme
        step_b003_quality_certify(
            lot=parent,
            quality=QualityCheck(
                rot_rate_percent=1.0,
                humidity_percent=7.0,
                sanitary_status="CONFORME",
                visual_observation="OK",
            ),
            tx_ref=build_tx_ref("B003", 2 + len(created_parent_lots)),
            ccfcc_actor=ACTOR_CCFCC,
        )
        created_parent_lots.append(parent)

    # On ajoute le lot principal comme 5e parent
    parent_lots_for_fus1 = [lot] + created_parent_lots

    # On force exactement 5 parents
    parent_lots_for_fus1 = parent_lots_for_fus1[:5]

    fus1 = step_b004_merge_to_fus1(
        base_parent_lot_id=lot.lot_id,
        parent_lots=parent_lots_for_fus1,
        tx_ref=build_tx_ref("B004", 1),
        fus1_cooperative=coop,
    )

    # Étape 5 transport
    tx_b005 = step_b005_transport_to_exporter(
        lot=fus1,
        exporter_name=ACTOR_EXPORTER,
        tx_ref=build_tx_ref("B005", 1),
        cooperative_name=coop.name,
    )

    # Étape 6 validation exportateur
    tx_b006 = step_b006_exporter_ready(
        lot=fus1,
        tx_ref=build_tx_ref("B006", 1),
        exporter_actor="LAWSON",
    )

    # Étape 7 OTR
    tx_b007 = step_b007_otr_customs_export(
        lot=fus1,
        tx_ref=build_tx_ref("B007", 1),
        otr_actor=ACTOR_OTR,
    )

    # Étape 8 importateur UE
    tx_b008 = step_b008_importer_delivered(
        lot=fus1,
        tx_ref=build_tx_ref("B008", 1),
        importer_actor=ACTOR_IMPORTER_EU,
    )

    # Tx B001 (création lot)
    tx_b001 = "0x"  # Les tx_ref demo proviennent des hashes ensure_tx_transfer.

    return Response(
        {
            "lot_id": lot.lot_id,
            "fus1_lot_id": fus1.lot_id,
            "status": fus1.status,
            "transactions": {
                "B002": tx_b002,
                "B003": tx_b003,
                "B004": None,
                "B005": tx_b005,
                "B006": tx_b006,
                "B007": tx_b007,
                "B008": tx_b008,
            },
        },
        status=status.HTTP_201_CREATED,
    )

