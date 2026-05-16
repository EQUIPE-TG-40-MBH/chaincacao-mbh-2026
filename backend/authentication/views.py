from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.models import User
from rest_framework_simplejwt.tokens import RefreshToken


@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    email = request.data.get('email')
    password = request.data.get('password')

    demo_accounts = {
        # Comptes dédiés pour simuler les acteurs du workflow (Étapes 1..8)
        'kodjo@chaincacao.tg': {
            'password': 'demo123',
            'role': 'farmer',
            'name': 'KODJO Mensah',
            'cooperative_id': 'COOP-TG-001'
        },
        'haho@chaincacao.tg': {
            'password': 'demo123',
            'role': 'cooperative',
            'name': 'Haho Cacao Union',
            'cooperative_id': 'COOP-TG-001'
        },
        'ccfcc@chaincacao.tg': {
            'password': 'demo123',
            'role': 'ccfcc',
            'name': 'CCFCC',
            'cooperative_id': None
        },
        'lawson@chaincacao.tg': {
            'password': 'demo123',
            'role': 'exporter',
            'name': 'Cacao-Togo SARL / Lawson',
            'cooperative_id': None
        },
        'otr@chaincacao.tg': {
            'password': 'demo123',
            'role': 'otr',
            'name': 'OTR Douanes',
            'cooperative_id': None
        },
        'bioeurope@chaincacao.tg': {
            'password': 'demo123',
            'role': 'importer',
            'name': 'BioEurope',
            'cooperative_id': None
        },

        # Comptes existants (compat)
        'cooperative@chaincacao.tg': {
            'password': 'demo123',
            'role': 'cooperative',
            'name': 'CAPRK Kpalimé',
            'cooperative_id': 'COOP-TG-001'
        },
        'exportateur@chaincacao.tg': {
            'password': 'demo123',
            'role': 'exportateur',
            'name': 'ChainCacao Export SARL',
            'cooperative_id': None
        },
        'ministere@chaincacao.tg': {
            'password': 'demo123',
            'role': 'ministere',
            'name': 'MAEP Togo',
            'cooperative_id': None
        },
    }

    if email in demo_accounts:
        account = demo_accounts[email]
        if account['password'] == password:
            user, created = User.objects.get_or_create(
                username=email,
                defaults={'email': email}
            )
            if created:
                user.set_password(password)
                user.save()

            refresh = RefreshToken.for_user(user)
            return Response({
                'token': str(refresh.access_token),
                'refresh': str(refresh),
                'role': account['role'],
                'name': account['name'],
                'cooperative_id': account['cooperative_id'],
                'email': email,
            })

    return Response(
        {'error': 'Email ou mot de passe incorrect'},
        status=status.HTTP_401_UNAUTHORIZED
    )


@api_view(['POST'])
@permission_classes([AllowAny])
def register_demo_data(request):
    from farmers.models import Cooperative, Farmer

    coop, _ = Cooperative.objects.get_or_create(
        cooperative_id='COOP-TG-001',
        defaults={
            'name': 'CAPRK Kpalimé',
            'region': 'Plateaux',
            'contact_email': 'caprk@chaincacao.tg',
            'contact_phone': '+22890000001',
        }
    )

    farmers_data = [
        {
            'first_name': 'Koami',
            'last_name': 'Agbeko',
            'phone': '+22890000002',
            'gps_latitude': 6.8913,
            'gps_longitude': 0.6502,
            'region': 'Plateaux',
            'village': 'Kpalimé',
            'language': 'ewe',
        },
        {
            'first_name': 'Akosua',
            'last_name': 'Mensah',
            'phone': '+22890000003',
            'gps_latitude': 6.8900,
            'gps_longitude': 0.6489,
            'region': 'Plateaux',
            'village': 'Kpalimé',
            'language': 'fr',
        },
        {
            'first_name': 'Mensah',
            'last_name': 'Koffi',
            'phone': '+22890000004',
            'gps_latitude': 6.8945,
            'gps_longitude': 0.6521,
            'region': 'Plateaux',
            'village': 'Kpalimé',
            'language': 'kabiye',
        },
    ]

    created_farmers = []
    for data in farmers_data:
        farmer, created = Farmer.objects.get_or_create(
            phone=data['phone'],
            defaults={**data, 'cooperative': coop}
        )
        created_farmers.append(farmer.farmer_id)

    return Response({
        'message': 'Données de démo créées avec succès',
        'cooperative': coop.cooperative_id,
        'farmers': created_farmers,
    })