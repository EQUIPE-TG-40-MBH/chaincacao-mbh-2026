# 🍫 ChainCacao
### Traçabilité Blockchain du Cacao Togolais · Conformité EUDR

> **MIABE Hackathon 2026** · Équipe TG-40 · Darollo Technologies Corporation · Lomé, Togo  
> *Thème : La Blockchain, levier de la conformité EUDR et du développement durable africain*

[![Contrat Polygon](https://img.shields.io/badge/Smart%20Contract-Polygon%20Amoy-8247E5?logo=polygon&logoColor=white)](https://amoy.polygonscan.com/address/0x72c5B32758000C6B6CbA364Cb4ef53aEF92948dc)
[![Backend Django](https://img.shields.io/badge/Backend-Django%20REST%20Framework-092E20?logo=django&logoColor=white)](https://chaincacao-mbh-2026.vercel.app)
[![Flutter](https://img.shields.io/badge/Mobile-Flutter-02569B?logo=flutter&logoColor=white)](https://chaincacao-mbh-2026.vercel.app)

---

## 🌍 Le Problème

Le cacao togolais traverse **4 à 6 intermédiaires non tracés** avant d'atteindre le marché européen. Résultat : l'agriculteur ne perçoit que **15 à 25 %** de la valeur réelle de sa récolte, sans aucune preuve de l'origine de son travail.

Depuis 2025, le **règlement européen EUDR** exige une traçabilité géographique prouvée pour tout cacao importé dans l'UE. Sans solution conforme, **le Togo risque de perdre l'accès à ses marchés européens**.

> 40 000 familles de producteurs de cacao sont directement concernées.

---

## ✅ La Solution

ChainCacao enregistre chaque lot sur la blockchain **Polygon Amoy** — de la parcelle agricole à l'exportateur — de manière **immuable, vérifiable et accessible à tous**, y compris sans smartphone ni connexion internet.

| Acteur | Ce que ChainCacao lui apporte |
|---|---|
| 🌱 **Agriculteur** | Enregistre son lot en 3 clics, reçoit un SMS de confirmation, sait enfin ce que son cacao rapporte |
| 🏭 **Coopérative** | Valide les arrivages, détecte automatiquement les fraudes de poids (seuil 5%) |
| 🚢 **Exportateur** | Génère le certificat de conformité EUDR en 1 clic |
| 🇪🇺 **Importateur** | Vérifie l'historique complet du lot sans créer de compte |

**🔊 Zéro exclusion** : interface audio en **Éwé et Kabiyè**, mode **100% hors-ligne** via USSD (`*550#`), synchronisation automatique dès le retour du réseau.

---

## 🔗 Liens

| Plateforme | URL |
|---|---|
| 🌐 Application principale | [chaincacao-mbh-2026.vercel.app](https://chaincacao-mbh-2026.vercel.app) |
| 🔍 Vérification publique | [chaincacao-mbh-2026.vercel.app/verifier](https://chaincacao-mbh-2026.vercel.app/#verifier) |
| 📡 Smart Contract Polygon Amoy | [`0x72c5B32758000C6B6CbA364Cb4ef53aEF92948dc`](https://amoy.polygonscan.com/address/0x72c5B32758000C6B6CbA364Cb4ef53aEF92948dc) |

---

## 🏗️ Structure du Projet

```
chaincacao-mbh-2026/
├── backend/          → API Python 3.11 / Django REST Framework
├── mobile/           → Application Flutter agriculteur (Android + PWA)
├── web_dashboard/    → Dashboard Flutter Web (coopérative & exportateur)
├── site_vitrine/     → Site HTML/CSS/JS de présentation
├── blockchain/       → Smart contracts Solidity (LotRegistry.sol)
├── assets/           → Logo, icônes, fichiers audio (Éwé, Kabiyè)
└── docs/             → Documentation technique et design system
```

---

## 🛠️ Stack Technique

| Couche | Technologie | Notes |
|---|---|---|
| Application mobile | Flutter & Dart | Android natif + PWA · Synthèse vocale locale |
| Dashboard web | Flutter Web | Interface coopérative & exportateur |
| Site vitrine | HTML / CSS / JavaScript | Déployé sur Vercel |
| Backend API | Python 3.11+ · Django REST Framework | Auth JWT · RBAC · OTP |
| Base de données | SQLite (MVP) → PostgreSQL | Migration prévue en production |
| Blockchain | Solidity v0.8.20+ · Web3.py | Polygon Amoy Testnet |
| USSD / SMS | AfricasTalking | `*550#` · disponible 24h/24 |
| Hébergement frontend | Vercel | CDN global |
| Hébergement backend | Render | Scalabilité horizontale |

---

## 🔐 Architecture & Sécurité

Le backend Django agit comme **passerelle de confiance** entre le terrain et la blockchain.

- **JWT** : tokens d'accès avec rotation des refresh tokens (durée : 7 jours en MVP)
- **RBAC** : rôles stricts — Producteur · Coopérative · Exportateur · Admin
- **Double validation OTP** : tout passage au statut `EXPORTED` exige un code envoyé par SMS/email
- **Clés privées** : jamais stockées en dur — injectées via variables d'environnement chiffrées
- **Hash SHA-256** : chaque changement d'état génère `SHA-256(UUID + Statut + Poids + GPS)` ancré sur Polygon

```solidity
// LotRegistry.sol — Polygon Amoy Testnet
// 0x72c5B32758000C6B6CbA364Cb4ef53aEF92948dc
function registerLotState(
    string memory _lotId,
    string memory _status,
    bytes32 _dataHash
) public onlyMinter;
```

---

## 🚀 Installation & Lancement

### Prérequis

- Python 3.11+
- Flutter 3.x
- Node.js 18+
- Un wallet configuré sur **Polygon Amoy Testnet**

### Backend Django

```bash
cd backend
python -m venv venv
source venv/bin/activate        # Linux/macOS
# venv\Scripts\activate         # Windows
pip install -r requirements.txt
cp .env.example .env            # Remplir les variables
python manage.py migrate
python manage.py runserver
```

### Application Flutter Mobile

```bash
cd mobile
flutter pub get
flutter run

# Build APK de production
dart run flutter_launcher_icons
flutter build apk --release
```

### Dashboard Flutter Web

```bash
cd web_dashboard
flutter pub get
flutter run -d chrome
```

### Site Vitrine

```bash
cd site_vitrine
# Ouvrir index.html dans le navigateur
# ou : Live Server dans VS Code
```

### Smart Contracts

```bash
cd blockchain
npm install
npx hardhat compile
npx hardhat ignition deploy ignition/modules/LotRegistry.js --network amoy
```

---

## 🔑 Variables d'Environnement

Copier `.env.example` en `.env` et compléter :

```env
# Django
SECRET_KEY=
DEBUG=True
DATABASE_URL=

# AfricasTalking
AT_USERNAME=
AT_API_KEY=

# Polygon Amoy
POLYGON_RPC_URL=https://rpc-amoy.polygon.technology
PRIVATE_KEY=
CONTRACT_ADDRESS=0x72c5B32758000C6B6CbA364Cb4ef53aEF92948dc

# JWT
JWT_SECRET=
```

---

## 📋 Organisation des Branches

```
main      → Production stable uniquement
develop   → Intégration de toutes les features
feature/* → Branches individuelles par développeur
```

Voir [`docs/design-system.md`](docs/design-system.md) pour les règles UI/UX.  
Voir [`docs/blockchain-config.md`](docs/blockchain-config.md) pour la configuration blockchain.

---

## 🎯 Scénario de Démo (5 minutes)

| Minute | Action |
|---|---|
| **Min 1** | L'agriculteur ouvre l'app → guide vocal en Éwé → enregistre un lot → QR code généré |
| **Min 2** | La coopérative scanne le QR → valide le poids → hash blockchain affiché en temps réel |
| **Min 3** | L'exportateur génère le certificat EUDR PDF conforme en 1 clic |
| **Min 4** | L'importateur européen vérifie l'historique complet depuis son téléphone, sans compte |
| **Min 5** | *"Ce lot vient de Koami, agriculteur à Kpalimé. Pour la première fois, il sait ce que son travail rapporte."* |

---

## 📦 État du MVP (Soumission Hackathon)

- [x] Smart Contract `LotRegistry.sol` déployé et vérifiable sur Polygon Amoy
- [x] Application mobile Flutter avec capture GPS résiliente et mode hors-ligne
- [x] Dashboard web avec génération de certificat EUDR et détection de fraude (seuil 5%)
- [x] API Django REST avec authentification JWT, RBAC et double validation OTP
- [x] Interface audio en Éwé et Kabiyè
- [x] Mode USSD (`*550#`) pour les zones sans internet
- [ ] IPFS — stockage décentralisé des documents (prévu en production)
- [ ] Celery + Redis — file d'attente asynchrone pour les transactions (prévu en production)

---

## 👥 Équipe TG-40

| Membre | Rôle | Branche |
|---|---|---|
| **HALALOUNA Trésor** | Chef de projet · Blockchain · Dashboard Web | `feature/blockchain` · `feature/dashboard-web` |
| **Georges GNANLE** | Développeur Flutter Mobile | `feature/app-mobile` |
| **EKOE Félicio** | Développeur Site Vitrine HTML/CSS/JS | `feature/site-vitrine` |
| **Jacques KOMBATE** | Développeur Backend Django | `feature/backend` |

---

## 📄 Licence

Projet réalisé dans le cadre du **MIABE Hackathon 2026** organisé par Darollo Technologies Corporation.

---

<div align="center">

**ChainCacao · Équipe TG-40 · Lomé, Togo · Mai 2026**

*La technologie au service du terroir, la transparence au service du paysan.*

</div>
