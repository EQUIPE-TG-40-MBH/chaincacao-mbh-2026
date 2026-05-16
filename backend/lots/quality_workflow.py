from __future__ import annotations

from dataclasses import dataclass
from typing import Optional, Dict, Any, List

from django.db import transaction
from django.utils import timezone

from .models import Lot, LotTransfer


@dataclass(frozen=True)
class QualityCheck:
    rot_rate_percent: float
    humidity_percent: float
    sanitary_status: str  # 'CONFORME' / 'NON_CONFORME'
    visual_observation: str


def _demo_hash(tx_ref: str) -> str:
    # Hash déterministe-ish côté backend pour rester cohérent sans blockchain réelle.
    # On évite le time.time() ici : tx_ref sera déjà unique par étape.
    import hashlib

    return "0x" + hashlib.sha256(tx_ref.encode()).hexdigest()


@transaction.atomic
def ensure_tx_transfer(lot: Lot, *, from_actor: str, to_actor: str, notes: str, tx_ref: str) -> str:
    """Crée une entrée LotTransfer + met à jour blockchain_hash sur le lot."""
    tx_hash = _demo_hash(tx_ref)
    LotTransfer.objects.create(
        lot=lot,
        from_actor=from_actor,
        to_actor=to_actor,
        notes=notes,
        blockchain_hash=tx_hash,
    )
    lot.blockchain_hash = tx_hash
    lot.updated_at = timezone.now()
    lot.save(update_fields=["blockchain_hash", "updated_at"])
    return tx_hash


@transaction.atomic
def step_b001_create_lot(
    *,
    farmer,  # Farmer instance
    cooperative,  # Cooperative instance
    gps_latitude: float,
    gps_longitude: float,
    weight_declared: float,
    culture_type: str,
    photo=None,
    recent_treatments: str,
    quality_observation: str,
    lot_id: str,
    status: str = "REGISTERED",
) -> Lot:
    if Lot.objects.filter(lot_id=lot_id).exists():
        return Lot.objects.get(lot_id=lot_id)

    lot = Lot.objects.create(
        lot_id=lot_id,
        farmer=farmer,
        cooperative=cooperative,
        weight_declared=float(weight_declared),
        weight_verified=None,
        gps_latitude=float(gps_latitude),
        gps_longitude=float(gps_longitude),
        culture_type=culture_type,
        photo=photo,
        status=status,
    )
    tx_ref = "B001"
    ensure_tx_transfer(
        lot,
        from_actor="SYSTEM",
        to_actor=farmer.full_name,
        notes="Création lot (Application mobile)",
        tx_ref=tx_ref,
    )

    # Stockage optionnel si champs existent (sinon ignoré)
    if hasattr(lot, "recent_treatments"):
        lot.recent_treatments = recent_treatments
    if hasattr(lot, "quality_observation"):
        lot.quality_observation = quality_observation
    lot.save()

    return lot


@transaction.atomic
def step_b002_receive_and_weigh(
    *,
    lot: Lot,
    cooperative_name: str,
    weight_real: float,
    tx_ref: str,
    payment_fcfa_per_kg: float = 550,
    cooperative_actor: str = "COOPERATIVE_HAHO_UNION",
    farmer_actor: str = "KODJO_MENSAH",
) -> str:
    lot.weight_verified = float(weight_real)
    lot.check_fraud()  # met fraud_alert + status/VALIDATED selon seuil

    # Force statut scénario
    lot.status = "IN_TRANSFER" if not lot.fraud_alert else "FRAUD_ALERT"
    lot.save(update_fields=["weight_verified", "fraud_alert", "fraud_details", "status", "updated_at"])

    diff = abs(lot.weight_declared - lot.weight_verified)
    notes = f"Reçu à la coopérative. Poids réel={weight_real} kg. Écart={diff:.1f} kg"

    tx_hash = ensure_tx_transfer(
        lot,
        from_actor=farmer_actor,
        to_actor=cooperative_name,
        notes=notes,
        tx_ref=tx_ref,
    )

    # Paiement simulé (pas de modèle paiement pour l'instant)
    _ = weight_real * payment_fcfa_per_kg
    return tx_hash


@transaction.atomic
def step_b003_quality_certify(
    *,
    lot: Lot,
    quality: QualityCheck,
    tx_ref: str,
    ccfcc_actor: str = "ADJALLÉ_CCFCC",
) -> str:
    # Enregistre les mesures si champs existent
    for field, value in {
        "rot_rate_percent": quality.rot_rate_percent,
        "humidity_percent": quality.humidity_percent,
        "sanitary_status": quality.sanitary_status,
        "visual_observation": quality.visual_observation,
    }.items():
        if hasattr(lot, field):
            setattr(lot, field, value)


    tx_hash = ensure_tx_transfer(
        lot,
        from_actor=ccfcc_actor,
        to_actor=lot.cooperative.name,
        notes=f"Contrôle qualité CCFCC: {quality.sanitary_status} (pourriture {quality.rot_rate_percent}%, humidité {quality.humidity_percent}%)",
        tx_ref=tx_ref,
    )

    lot.status = "CERTIFIED" if quality.sanitary_status == "CONFORME" else "FRAUD_ALERT"
    lot.save(update_fields=["status", "updated_at"])
    return tx_hash


@transaction.atomic
def step_b004_merge_to_fus1(
    *,
    base_parent_lot_id: str,
    parent_lots: List[Lot],
    tx_ref: str,
    fus1_cooperative,
) -> Lot:
    if len(parent_lots) != 5:
        raise ValueError("Fusion scénario attend exactement 5 lots parents")

    new_lot_id = f"{base_parent_lot_id}-FUS1"
    if Lot.objects.filter(lot_id=new_lot_id).exists():
        return Lot.objects.get(lot_id=new_lot_id)

    total_weight = sum(l.weight_verified or l.weight_declared for l in parent_lots)

    first = parent_lots[0]
    merged = Lot.objects.create(
        lot_id=new_lot_id,
        farmer=first.farmer,
        cooperative=fus1_cooperative,
        weight_declared=float(total_weight),
        weight_verified=float(total_weight),
        gps_latitude=first.gps_latitude,
        gps_longitude=first.gps_longitude,
        culture_type=first.culture_type,
        status="VALIDATED",
    )

    ensure_tx_transfer(
        merged,
        from_actor="COOPERATIVE_HAHO_UNION",
        to_actor=fus1_cooperative.name,
        notes=f"Fusion: {', '.join([l.lot_id for l in parent_lots])}",
        tx_ref=tx_ref,
    )

    for p in parent_lots:
        p.status = "EXPORTED"
        p.save(update_fields=["status", "updated_at"])

    return merged


@transaction.atomic
def step_b005_transport_to_exporter(
    *,
    lot: Lot,
    exporter_name: str,
    tx_ref: str,
    cooperative_name: str,
) -> str:
    return ensure_tx_transfer(
        lot,
        from_actor=cooperative_name,
        to_actor=exporter_name,
        notes=f"Transport: {cooperative_name} -> {exporter_name}",
        tx_ref=tx_ref,
    )


@transaction.atomic
def step_b006_exporter_ready(
    *,
    lot: Lot,
    tx_ref: str,
    exporter_actor: str = "LAWSON",
) -> str:
    tx_hash = ensure_tx_transfer(
        lot,
        from_actor=lot.cooperative.name,
        to_actor=exporter_actor,
        notes="Validation exportateur: PRÊT POUR EXPORT",
        tx_ref=tx_ref,
    )
    # adapte status si champs existent
    lot.status = "EXPORTED"
    lot.save(update_fields=["status", "updated_at"])
    return tx_hash


@transaction.atomic
def step_b007_otr_customs_export(
    *,
    lot: Lot,
    tx_ref: str,
    otr_actor: str = "OTR",
) -> str:
    return ensure_tx_transfer(
        lot,
        from_actor="EXPORTATEUR",
        to_actor="OTR",
        notes="Contrôle douanier OTR: EXPORT AUTORISÉ",
        tx_ref=tx_ref,
    )


@transaction.atomic
def step_b008_importer_delivered(
    *,
    lot: Lot,
    tx_ref: str,
    importer_actor: str = "BIOEUROPE",
) -> str:
    tx_hash = ensure_tx_transfer(
        lot,
        from_actor="OTR",
        to_actor=importer_actor,
        notes="Réception importateur: LIVRÉ CONFORME",
        tx_ref=tx_ref,
    )
    lot.status = "CERTIFIED"
    lot.save(update_fields=["status", "updated_at"])
    return tx_hash

