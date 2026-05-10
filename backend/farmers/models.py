from django.db import models
import qrcode
import io
from django.core.files.base import ContentFile


class Cooperative(models.Model):
    cooperative_id = models.CharField(max_length=50, unique=True)
    name = models.CharField(max_length=200)
    region = models.CharField(max_length=100)
    contact_email = models.EmailField()
    contact_phone = models.CharField(max_length=20)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.cooperative_id} — {self.name}"


class Farmer(models.Model):
    farmer_id = models.CharField(max_length=50, unique=True)
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    phone = models.CharField(max_length=20)
    cooperative = models.ForeignKey(
        Cooperative, on_delete=models.CASCADE, related_name='farmers'
    )
    gps_latitude = models.FloatField(null=True, blank=True)
    gps_longitude = models.FloatField(null=True, blank=True)
    region = models.CharField(max_length=100)
    village = models.CharField(max_length=100)
    language = models.CharField(
        max_length=10,
        choices=[('fr', 'Français'), ('ewe', 'Éwé'), ('kabiye', 'Kabiyè')],
        default='fr'
    )
    qr_code = models.ImageField(upload_to='qr_codes/', null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    is_active = models.BooleanField(default=True)

    def save(self, *args, **kwargs):
        if not self.farmer_id:
            count = Farmer.objects.filter(
                cooperative=self.cooperative
            ).count() + 1
            self.farmer_id = f"{self.cooperative.cooperative_id}-{count:03d}"

        # Générer le QR code automatiquement
        if not self.qr_code:
            qr = qrcode.QRCode(version=1, box_size=10, border=4)
            qr.add_data(self.farmer_id)
            qr.make(fit=True)
            img = qr.make_image(fill_color="black", back_color="white")
            buffer = io.BytesIO()
            img.save(buffer, format='PNG')
            file_name = f'qr_{self.farmer_id}.png'
            self.qr_code.save(
                file_name,
                ContentFile(buffer.getvalue()),
                save=False
            )

        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.farmer_id} — {self.first_name} {self.last_name}"

    @property
    def full_name(self):
        return f"{self.first_name} {self.last_name}"

    @property
    def gps_coordinates(self):
        if self.gps_latitude and self.gps_longitude:
            return f"{self.gps_latitude}° N, {self.gps_longitude}° E"
        return "Non défini"