from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("lots", "0004_lot_humidity_percent_lot_quality_observation_and_more"),
    ]

    operations = [
        migrations.AddField(
            model_name="lot",
            name="gps_forced",
            field=models.BooleanField(default=False),
        ),
        migrations.AlterField(
            model_name="lot",
            name="status",
            field=models.CharField(
                choices=[
                    ("REGISTERED", "Enregistré"),
                    ("IN_TRANSFER", "En transit"),
                    ("VALIDATED", "Validé"),
                    ("FRAUD_ALERT", "Alerte fraude"),
                    ("EXPORTED", "Exporté"),
                    ("CERTIFIED", "Certifié"),
                    ("CUSTOMS_CLEARED", "Dédouané"),
                ],
                default="REGISTERED",
                max_length=20,
            ),
        ),
    ]
