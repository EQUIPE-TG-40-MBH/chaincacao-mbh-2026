from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('lots', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='lot',
            name='recent_treatments',
            field=models.TextField(null=True, blank=True),
        ),
        migrations.AddField(
            model_name='lot',
            name='quality_observation',
            field=models.TextField(null=True, blank=True),
        ),
        migrations.AddField(
            model_name='lot',
            name='rot_rate_percent',
            field=models.FloatField(null=True, blank=True),
        ),
        migrations.AddField(
            model_name='lot',
            name='humidity_percent',
            field=models.FloatField(null=True, blank=True),
        ),
        migrations.AddField(
            model_name='lot',
            name='sanitary_status',
            field=models.CharField(max_length=20, null=True, blank=True),
        ),
        migrations.AddField(
            model_name='lot',
            name='visual_observation',
            field=models.TextField(null=True, blank=True),
        ),
    ]

