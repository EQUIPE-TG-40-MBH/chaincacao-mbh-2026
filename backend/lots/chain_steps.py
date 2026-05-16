from dataclasses import dataclass


@dataclass(frozen=True)
class StepResult:
    tx_ref: str
    lot_id: str
    status: str


def build_tx_ref(tx_prefix: str, seq: int) -> str:
    return f"{tx_prefix}{seq:03d}"

