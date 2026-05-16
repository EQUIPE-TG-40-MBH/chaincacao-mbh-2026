from rest_framework import generics, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from django.utils import timezone
from django.db import transaction
from farmers.models import Cooperative, Farmer
from .models import Lot, LotTransfer, Certificate
from .serializers import (
    LotSerializer,
    LotPublicSerializer,
    LotTransferSerializer,
    CertificateSerializer,
)

import csv
import io
import hashlib
import time
import os
import datetime
import json
from django.core.mail import EmailMessage
from web3 import Web3
from django.conf import settings


def generate_demo_hash(lot_id: str) -> str:
    data = f"{lot_id}{time.time()}"
    return "0x" + hashlib.sha256(data.encode()).hexdigest()


def call_smart_contract_update_status(lot_id: str, new_status: str) -> str:
    """Interagit (ou fallback) avec le contrat LotRegistry sur Polygon Amoy."""

    private_key = getattr(settings, "BLOCKCHAIN_PRIVATE_KEY", None)
    rpc_url = getattr(settings, "AMOY_RPC_URL", None)
    contract_address = getattr(
        settings,
        "CONTRACT_ADDRESS",
        "0x72c5B32758000C6B6CbA364Cb4ef53aEF92948dc",
    )

    if not rpc_url or not private_key:
        return generate_demo_hash(lot_id)

    w3 = Web3(Web3.HTTPProvider(rpc_url))
    account = w3.eth.account.from_key(private_key)

    minimal_abi = [
        {
            "inputs": [
                {"name": "_lotId", "type": "string"},
                {"name": "_newStatus", "type": "string"},
            ],
            "name": "updateStatus",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function",
        }
    ]

    contract = w3.eth.contract(address=contract_address, abi=minimal_abi)

    nonce = w3.eth.get_transaction_count(account.address)

    tx = contract.functions.updateStatus(lot_id, new_status).build_transaction(
        {
            "from": account.address,
            "nonce": nonce,
            "gas": 150000,
            "maxFeePerGas": w3.to_wei("2", "gwei"),
            "maxPriorityFeePerGas": w3.to_wei("1", "gwei"),
        }
    )

    signed_tx = w3.eth.account.sign_transaction(tx, private_key)
    tx_hash = w3.eth.send_raw_transaction(signed_tx.raw_transaction)
    return w3.to_hex(tx_hash)


class LotListView(generics.ListCreateAPIView):
    serializer_class = LotSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Lot.objects.all().order_by("-registered_at")
        cooperative_id = self.request.query_params.get("cooperative")
        status_filter = self.request.query_params.get("status")
        farmer_id = self.request.query_params.get("farmer")

        if cooperative_id:
            queryset = queryset.filter(cooperative__cooperative_id=cooperative_id)
        if status_filter:
            queryset = queryset.filter(status=status_filter)
        if farmer_id:
            queryset = queryset.filter(farmer__farmer_id=farmer_id)

        return queryset

    def perform_create(self, serializer):
        lot = serializer.save()
        lot.blockchain_hash = generate_demo_hash(lot.lot_id)
        lot.save()

        LotTransfer.objects.create(
            lot=lot,
            from_actor="SYSTEM",
            to_actor=lot.farmer.full_name,
            notes="Enregistrement initial du lot",
            blockchain_hash=lot.blockchain_hash,
        )


class LotDetailView(generics.RetrieveUpdateAPIView):
    queryset = Lot.objects.all()
    serializer_class = LotSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = "lot_id"


@api_view(["GET"])
@permission_classes([AllowAny])
def lot_public(request, lot_id):
    try:
        lot = Lot.objects.get(lot_id=lot_id)
        return Response(LotPublicSerializer(lot).data)
    except Lot.DoesNotExist:
        return Response(
            {"error": "Lot non trouvé"},
            status=status.HTTP_404_NOT_FOUND,
        )


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def lot_transfer(request, lot_id):
    try:
        lot = Lot.objects.get(lot_id=lot_id)
    except Lot.DoesNotExist:
        return Response(
            {"error": "Lot non trouvé"},
            status=status.HTTP_404_NOT_FOUND,
        )

    weight_verified = request.data.get("weight_verified")
    if not weight_verified:
        return Response(
            {"error": "Le poids vérifié est obligatoire pour valider un transfert"},
            status=status.HTTP_400_BAD_REQUEST,
        )

    from_actor = request.data.get("from_actor", "PRODUCTEUR")
    to_actor = request.data.get("to_actor", "COOPERATIVE")
    notes = request.data.get("notes", "")

    try:
        if weight_verified is not None:
            lot.weight_verified = float(weight_verified)
            lot.check_fraud()
    except (ValueError, TypeError):
        return Response({"error": "Poids invalide"}, status=status.HTTP_400_BAD_REQUEST)

    blockchain_hash = generate_demo_hash(lot_id)

    # Champs optionnels
    recent_treatments = request.data.get("recent_treatments")
    notes_quality = request.data.get("notes_quality")

    if notes_quality is not None:
        lot.quality_observation = notes_quality
    if recent_treatments is not None:
        lot.recent_treatments = recent_treatments

    LotTransfer.objects.create(
        lot=lot,
        from_actor=from_actor,
        to_actor=to_actor,
        notes=notes,
        blockchain_hash=blockchain_hash,
    )

    lot.blockchain_hash = blockchain_hash
    if not lot.fraud_alert:
        lot.status = "IN_TRANSFER"
    lot.save()

    return Response(
        {
            "message": "Transfert enregistré avec succès",
            "lot_id": lot.lot_id,
            "status": lot.status,
            "fraud_alert": lot.fraud_alert,
            "fraud_details": lot.fraud_details,
            "blockchain_hash": blockchain_hash,
        }
    )


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def generate_eudr_certificate(request):
    lot_ids = request.data.get("lot_ids", [])
    if not lot_ids:
        return Response(
            {"error": "Aucun lot sélectionné"},
            status=status.HTTP_400_BAD_REQUEST,
        )

    lots = Lot.objects.filter(lot_id__in=lot_ids)
    if not lots.exists():
        return Response(
            {"error": "Lots non trouvés"},
            status=status.HTTP_404_NOT_FOUND,
        )

    total_weight = sum(float(l.weight_verified or l.weight_declared or 0) for l in lots)
    blockchain_hash = generate_demo_hash("EUDR")

    certificate = Certificate.objects.create(
        cert_type="EUDR",
        issued_by="ChainCacao Export SARL",
        total_weight=total_weight,
        blockchain_hash=blockchain_hash,
    )
    certificate.lots.set(lots)

    for lot in lots:
        lot.status = "EXPORTED"
        lot.save()
        LotTransfer.objects.create(
            lot=lot,
            from_actor="EXPORTATEUR",
            to_actor="IMPORTATEUR_EU",
            notes=f"Inclus dans certificat EUDR {certificate.cert_id}",
            blockchain_hash=blockchain_hash,
        )

    return Response(
        {
            "message": "Certificat EUDR généré avec succès",
            "certificate": CertificateSerializer(certificate).data,
        },
        status=status.HTTP_201_CREATED,
    )


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def attach_certificate(request, lot_id):
    try:
        lot = Lot.objects.get(lot_id=lot_id)
    except Lot.DoesNotExist:
        return Response(
            {"error": "Lot non trouvé"},
            status=status.HTTP_404_NOT_FOUND,
        )

    cert_type = request.data.get("cert_type", "EUDR")
    blockchain_hash = generate_demo_hash(lot_id + cert_type)

    certificate = Certificate.objects.create(
        cert_type=cert_type,
        issued_by=request.data.get("issued_by", "ChainCacao"),
        total_weight=lot.weight_verified or lot.weight_declared,
        blockchain_hash=blockchain_hash,
    )
    certificate.lots.add(lot)

    lot.status = "CERTIFIED"
    lot.save()

    return Response(
        {
            "message": "Certificat attaché avec succès",
            "certificate": CertificateSerializer(certificate).data,
        },
        status=status.HTTP_201_CREATED,
    )


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def validate_quality_ccfcc(request, lot_id):
    """Action réelle du CCFCC pour certifier la qualité."""
    try:
        lot = Lot.objects.get(lot_id=lot_id)
        lot.status = "VALIDATED"

        blockchain_hash = call_smart_contract_update_status(lot_id, "VALIDATED")
        lot.blockchain_hash = blockchain_hash
        lot.save()

        LotTransfer.objects.create(
            lot=lot,
            from_actor="CCFCC",
            to_actor="COOPERATIVE",
            notes="Qualité certifiée conforme aux normes export.",
            blockchain_hash=blockchain_hash,
        )

        return Response({"message": "Lot certifié avec succès", "status": lot.status})
    except Lot.DoesNotExist:
        return Response({"error": "Lot non trouvé"}, status=404)


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def validate_customs_otr(request, lot_id):
    """Action réelle de l'OTR pour le dédouanement."""
    try:
        lot = Lot.objects.get(lot_id=lot_id)
        if lot.status != "EXPORTED":
            return Response(
                {"error": "Le lot doit être en statut EXPORTED"},
                status=400,
            )

        blockchain_hash = call_smart_contract_update_status(lot_id, "CUSTOMS_CLEARED")

        LotTransfer.objects.create(
            lot=lot,
            from_actor="OTR",
            to_actor="PORT_LOME",
            notes="Dédouanement export validé. Taxes acquittées.",
            blockchain_hash=blockchain_hash,
        )

        return Response(
            {
                "message": "Dédouanement validé sur la blockchain",
                "tx_hash": blockchain_hash,
            }
        )
    except Lot.DoesNotExist:
        return Response({"error": "Lot non trouvé"}, status=404)


@api_view(["POST"])
@permission_classes([IsAuthenticated])
@transaction.atomic
def merge_lots(request):
    """Fusion de lots en 1 lot enfant. Scénario: exactement 5 parents."""
    data_in = request.data
    # Vérification que lot_ids est présent et est une liste
    lot_ids = data_in.get("lot_ids")
    if not isinstance(lot_ids, list):
        return Response(
            {"error": "Le champ 'lot_ids' doit être une liste d'identifiants"},
            status=status.HTTP_400_BAD_REQUEST,
        )

    base_parent_lot_id = request.data.get("base_parent_lot_id")

    if len(lot_ids) < 2:
        return Response(
            {"error": "Selectionnez au moins 2 lots a fusionner"},
            status=status.HTTP_400_BAD_REQUEST,
        )

    lots = Lot.objects.filter(lot_id__in=lot_ids)
    if lots.count() != len(lot_ids):
        return Response(
            {"error": "Certains lots selectionnés sont introuvables"},
            status=status.HTTP_400_BAD_REQUEST,
        )

    total_weight = sum(float(l.weight_verified or l.weight_declared) for l in lots)

    new_lot_id = None
    if base_parent_lot_id and base_parent_lot_id in lot_ids and len(lot_ids) == 5:
        new_lot_id = f"{base_parent_lot_id}-FUS1"

    merged_status = "VALIDATED"
    if not new_lot_id:
        year = timezone.now().year
        count = Lot.objects.count() + 1
        new_lot_id = f"TG-{year}-{count:04d}-MERGE"

    data = f"{new_lot_id}{time.time()}"
    blockchain_hash = "0x" + hashlib.sha256(data.encode()).hexdigest()

    first_lot = lots.first()
    merged_lot = Lot.objects.create(
        lot_id=new_lot_id,
        farmer=first_lot.farmer,
        cooperative=first_lot.cooperative,
        weight_declared=total_weight,
        weight_verified=total_weight,
        culture_type=first_lot.culture_type,
        gps_latitude=first_lot.gps_latitude,
        gps_longitude=first_lot.gps_longitude,
        status=merged_status,
        blockchain_hash=blockchain_hash,
    )

    LotTransfer.objects.create(
        lot=merged_lot,
        from_actor="FUSION",
        to_actor=first_lot.cooperative.name,
        notes=f"Fusion des lots: {', '.join(lot_ids)}",
        blockchain_hash=blockchain_hash,
    )

    for lot in lots:
        lot.status = "EXPORTED"
        lot.save()

    return Response(
        {
            "message": "Lots fusionnes avec succes",
            "merged_lot": LotSerializer(merged_lot).data,
            "source_lots": lot_ids,
            "total_weight": total_weight,
            "blockchain_hash": blockchain_hash,
        },
        status=status.HTTP_201_CREATED,
    )


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def register_cooperative_lot(request):
    cooperative_id = request.data.get("cooperative_id")
    weight = request.data.get("weight_declared")

    if not cooperative_id or not weight:
        return Response(
            {"error": "Champs manquants : cooperative_id et weight_declared sont requis"},
            status=status.HTTP_400_BAD_REQUEST,
        )

    culture_type = request.data.get("culture_type", "cacao")
    gps_latitude = request.data.get("gps_latitude", 6.8913)
    gps_longitude = request.data.get("gps_longitude", 0.6502)
    harvest_date = request.data.get("harvest_date")
    notes = request.data.get("notes", "")

    try:
        cooperative = Cooperative.objects.get(cooperative_id=cooperative_id)
    except Cooperative.DoesNotExist:
        return Response(
            {"error": "Cooperative introuvable"},
            status=status.HTTP_404_NOT_FOUND,
        )

    farmer, _ = Farmer.objects.get_or_create(
        phone="COOP-INTERNAL",
        defaults={
            "first_name": "Production",
            "last_name": "Cooperative",
            "cooperative": cooperative,
            "region": cooperative.region,
            "village": cooperative.name,
            "language": "fr",
        },
    )

    year = timezone.now().year
    count = Lot.objects.count() + 1
    lot_id = f"TG-{year}-{count:04d}"

    data = f"{lot_id}{time.time()}"
    blockchain_hash = "0x" + hashlib.sha256(data.encode()).hexdigest()

    lot = Lot.objects.create(
        lot_id=lot_id,
        farmer=farmer,
        cooperative=cooperative,
        weight_declared=float(weight),
        weight_verified=float(weight),
        culture_type=culture_type,
        gps_latitude=float(gps_latitude),
        gps_longitude=float(gps_longitude),
        status="REGISTERED",
        blockchain_hash=blockchain_hash,
    )

    LotTransfer.objects.create(
        lot=lot,
        from_actor=cooperative.name,
        to_actor="STOCK COOPERATIF",
        notes=notes or f"Recolte cooperative - {harvest_date or ''}",
        blockchain_hash=blockchain_hash,
    )

    return Response(
        {
            "message": "Recolte cooperative enregistree",
            "lot": LotSerializer(lot).data,
            "blockchain_hash": blockchain_hash,
        },
        status=status.HTTP_201_CREATED,
    )


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def email_lots_csv(request):
    """Génère un CSV des lots filtrés et l'envoie par email à l'utilisateur."""

    cooperative_id = request.data.get("cooperative_id")
    start_date = request.data.get("start_date")
    end_date = request.data.get("end_date")
    detailed = request.data.get("detailed", False)

    queryset = Lot.objects.filter(cooperative__cooperative_id=cooperative_id)

    # Parsing des dates (ISO YYYY-MM-DD)
    if start_date:
        start_datetime = datetime.datetime.strptime(start_date, "%Y-%m-%d").date()
        queryset = queryset.filter(registered_at__date__gte=start_datetime)

    if end_date:
        end_datetime = datetime.datetime.strptime(end_date, "%Y-%m-%d").date()
        queryset = queryset.filter(registered_at__date__lte=end_datetime)

    output = io.StringIO()
    writer = csv.writer(output)

    headers = [
        "ID Lot",
        "Producteur",
        "Culture",
        "Poids Declare (kg)",
        "Poids Verifie (kg)",
        "Statut",
        "Date",
    ]
    if detailed:
        headers.append("Historique des Transferts")

    writer.writerow(headers)

    for lot in queryset:
        transfers_history = (
            lot.transfers.all()
            .order_by("transferred_at")
            .values_list("from_actor", "to_actor", "notes", "transferred_at")
        )
        formatted_history = " | ".join(
            [
                f"{t[0] or 'N/A'} -> {t[1] or 'N/A'} ({t[2] or ''}) [{t[3].strftime('%Y-%m-%d %H:%M')}]"
                for t in transfers_history
            ]
        )

        row_data = [
            lot.lot_id,
            lot.farmer.full_name,
            lot.culture_type,
            lot.weight_declared,
            lot.weight_verified,
            lot.status,
            lot.registered_at.strftime("%Y-%m-%d %H:%M:%S"),
        ]
        if detailed:
            row_data.append(formatted_history)

        writer.writerow(row_data)

    csv_content = output.getvalue()
    output.close()

    user_email = request.user.email
    if not user_email:
        return Response(
            {"error": "L'utilisateur n'a pas d'adresse email configurée"},
            status=400,
        )

    try:
        email = EmailMessage(
            subject=f"Export de vos lots ChainCacao - {timezone.now().date()}",
            body=(
                "Veuillez trouver en pièce jointe l'export CSV de vos lots de cacao "
                "demandé depuis le dashboard."
            ),
            from_email="noreply@chaincacao.tg",
            to=[user_email],
        )

        email.attach(
            f"export_lots_{timezone.now().timestamp()}.csv",
            csv_content,
            "text/csv",
        )
        email.send()

        return Response({"message": f"Le fichier CSV a été envoyé à {user_email}"})
    except Exception as e:
        return Response({"error": str(e)}, status=500)
