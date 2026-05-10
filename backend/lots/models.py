from django.db import models
from farmers.models import Farmer, Cooperative


class Lot(models.Model):
    STATUS_CHOICES = [
        ('REGISTERED', 'Enregistré'),
        ('IN_TRANSFER', 'En transit'),
        ('VALIDATED', 'Validé'),
        ('FRAUD_ALERT', 'Alerte fraude'),
        ('EXPORTED', 'Exporté'),
        ('CERTIFIED', 'Certifié'),
    ]

    CULTURE_CHOICES = [
        ('cacao', 'Cacao'),
        ('cafe', 'Café'),
    ]

    lot_id = models.CharField(max_length=50, unique=True)
    farmer = models.ForeignKey(
        Farmer, on_delete=models.CASCADE, related_name='lots'
    )
    cooperative = models.ForeignKey(
        Cooperative, on_delete=models.CASCADE, related_name='lots'
    )
    weight_declared = models.FloatField()
    weight_verified = models.FloatField(null=True, blank=True)
    gps_latitude = models.FloatField(null=True, blank=True)
    gps_longitude = models.FloatField(null=True, blank=True)
    culture_type = models.CharField(
        max_length=10, choices=CULTURE_CHOICES, default='cacao'
    )
    photo = models.ImageField(upload_to='lots/', null=True, blank=True)
    status = models.CharField(
        max_length=20, choices=STATUS_CHOICES, default='REGISTERED'
    )
    blockchain_hash = models.CharField(max_length=200, null=True, blank=True)
    fraud_alert = models.BooleanField(default=False)
    fraud_details = models.TextField(null=True, blank=True)
    registered_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def save(self, *args, **kwargs):
        if not self.lot_id:
            from django.utils import timezone
            year = timezone.now().year
            count = Lot.objects.count() + 1
            self.lot_id = f"TG-{year}-{count:04d}"
        super().save(*args, **kwargs)

    def check_fraud(self):
        if self.weight_verified and self.weight_declared:
            diff = abs(self.weight_declared - self.weight_verified)
            percentage = (diff / self.weight_declared) * 100
            if percentage > 5:
                self.fraud_alert = True
                self.status = 'FRAUD_ALERT'
                self.fraud_details = (
                    f"Écart de {diff:.1f} kg ({percentage:.1f}%) "
                    f"entre poids déclaré ({self.weight_declared} kg) "
                    f"et poids vérifié ({self.weight_verified} kg)"
                )
            else:
                self.fraud_alert = False
                self.status = 'VALIDATED'
        self.save()

    def __str__(self):
        return f"{self.lot_id} — {self.farmer.full_name}"

    @property
    def gps_coordinates(self):
        if self.gps_latitude and self.gps_longitude:
            return f"{self.gps_latitude}° N, {self.gps_longitude}° E"
        return "Non défini"


class LotTransfer(models.Model):
    lot = models.ForeignKey(
        Lot, on_delete=models.CASCADE, related_name='transfers'
    )
    from_actor = models.CharField(max_length=100)
    to_actor = models.CharField(max_length=100)
    notes = models.TextField(null=True, blank=True)
    blockchain_hash = models.CharField(max_length=200, null=True, blank=True)
    transferred_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.lot.lot_id} : {self.from_actor} → {self.to_actor}"


class Certificate(models.Model):
    CERT_TYPE_CHOICES = [
        ('EUDR', 'EUDR'),
        ('FAIRTRADE', 'Fairtrade'),
        ('BIO', 'Bio'),
        ('RAINFOREST', 'Rainforest Alliance'),
    ]

    cert_id = models.CharField(max_length=100, unique=True)
    lots = models.ManyToManyField(Lot, related_name='certificates')
    cert_type = models.CharField(max_length=20, choices=CERT_TYPE_CHOICES)
    issued_by = models.CharField(max_length=200)
    total_weight = models.FloatField()
    blockchain_hash = models.CharField(max_length=200, null=True, blank=True)
    pdf_file = models.FileField(upload_to='certificates/', null=True, blank=True)
    issued_at = models.DateTimeField(auto_now_add=True)

    def save(self, *args, **kwargs):
        if not self.cert_id:
            from django.utils import timezone
            year = timezone.now().year
            count = Certificate.objects.count() + 1
            self.cert_id = f"EUDR-TG-{year}-{count:04d}"
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.cert_id} — {self.cert_type}"