# ChainCacao — Design System
> Version 1.0 · MIABE Hackathon 2026  
> Ce fichier est la **référence unique** pour toute l'équipe.  
> Félicio (site vitrine), Georges (app mobile), Trésor (dashboard web) : tout le monde suit ces règles sans exception.

---

## 1. Logo

Le logo officiel est dans `/assets/logo/`.

| Fichier | Usage |
|---|---|
| `chaincacao_logo.png` | Usage général sur fond sombre |
| `chaincacao_logo_light.png` | Sur fond clair (à exporter depuis le PNG original) |
| `chaincacao_logo_icon.png` | Icône seule (le pin), pour favicon et app icon |

**Règles d'usage du logo :**
- Ne jamais déformer ou étirer le logo
- Ne jamais changer les couleurs du logo
- Espace minimum autour du logo : 16px de chaque côté
- Sur fond clair → utiliser la version avec couleurs originales
- Sur fond sombre → utiliser la version PNG originale (fond noir)

---

## 2. Palette de couleurs

### Couleurs principales

```
Cacao profond   #3D1C02   → Fonds, headers, textes titres
Or chaud        #C9933A   → Boutons CTA, bordures actives, icônes clés
Or vif          #E8B04B   → Hover, highlights, animations
Vert feuille    #2D5016   → Succès, validation, lots certifiés
Crème           #FAF6EE   → Fonds de pages, cartes, surfaces claires
```

### Couleurs secondaires

```
Gris texte      #8A7A6A   → Texte secondaire, labels, placeholders
Orange alerte   #D97706   → Alertes fraude, bannière hors ligne
Bleu transit    #1D4ED8   → Lots en transit, liens, badges info
Rouge erreur    #DC2626   → Erreurs de saisie, validations échouées
Blanc           #FFFFFF   → Texte sur fond sombre, icônes sur boutons
```

### Utilisation par contexte

```
Fond de page principale     → #FAF6EE (crème)
Fond header / navbar        → #3D1C02 (cacao)
Bouton principal            → #C9933A (or chaud)
Bouton au survol (hover)    → #E8B04B (or vif)
Texte principal             → #3D1C02 (cacao)
Texte secondaire            → #8A7A6A (gris)
Lot validé / certifié       → #2D5016 (vert)
Lot en attente              → #D97706 (orange)
Lot en transit              → #1D4ED8 (bleu)
Alerte fraude               → #DC2626 (rouge)
```

---

## 3. Typographie

### Polices à importer (Google Fonts)

Coller ce lien dans le `<head>` de chaque page HTML, ou dans le fichier de thème Flutter :

```html
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Epilogue:wght@400;500;600&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
```

### Hiérarchie typographique

| Élément | Police | Taille desktop | Taille mobile | Graisse | Couleur |
|---|---|---|---|---|---|
| H1 — Titre principal | Playfair Display | 48px | 32px | 700 | #3D1C02 |
| H2 — Titre section | Playfair Display | 36px | 26px | 600 | #3D1C02 |
| H3 — Sous-titre | Epilogue | 24px | 20px | 600 | #3D1C02 |
| Corps de texte | Epilogue | 18px | 16px | 400 | #3D1C02 |
| Texte secondaire | Epilogue | 16px | 14px | 400 | #8A7A6A |
| Label / Caption | Epilogue | 14px | 13px | 500 | #8A7A6A |
| Hash blockchain | JetBrains Mono | 14px | 13px | 400 | #3D1C02 |
| Bouton | Epilogue | 16px | 16px | 600 | #FFFFFF |

### Règles typographiques
- Taille minimum absolue : **14px** (accessibilité)
- Interligne (line-height) : **1.6** pour le corps de texte
- Ne jamais utiliser une autre police que ces trois
- Les titres en Playfair Display, tout le reste en Epilogue

---

## 4. Espacements

Système basé sur des multiples de 8px :

```
4px   → Espacement micro (entre icône et texte)
8px   → Espacement XS (padding interne petit)
16px  → Espacement S (padding standard)
24px  → Espacement M (entre éléments d'une section)
32px  → Espacement L (entre sections)
48px  → Espacement XL (grandes séparations)
64px  → Espacement XXL (entre sections de page)
```

---

## 5. Composants

### Bouton principal (CTA)

```
Fond            → #C9933A
Texte           → #FFFFFF
Police          → Epilogue 600
Taille texte    → 16px
Hauteur         → 56px minimum (accessibilité tactile)
Padding         → 16px 32px
Coins           → 8px (border-radius)
Hover           → fond #E8B04B
Ombre           → none
```

**HTML/CSS exemple :**
```css
.btn-primary {
  background-color: #C9933A;
  color: #FFFFFF;
  font-family: 'Epilogue', sans-serif;
  font-weight: 600;
  font-size: 16px;
  height: 56px;
  padding: 0 32px;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  transition: background-color 0.2s ease;
}
.btn-primary:hover {
  background-color: #E8B04B;
}
```

---

### Bouton secondaire

```
Fond            → transparent
Bordure         → 2px solid #C9933A
Texte           → #3D1C02
Police          → Epilogue 600
Hauteur         → 56px minimum
Padding         → 0 32px
Coins           → 8px
Hover           → fond #FAF6EE
```

---

### Carte (Card)

```
Fond            → #FFFFFF
Bordure         → none
Ombre           → 0 2px 12px rgba(61, 28, 2, 0.10)
Coins           → 12px
Padding         → 24px
```

**CSS :**
```css
.card {
  background: #FFFFFF;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(61, 28, 2, 0.10);
  padding: 24px;
}
```

---

### Badges de statut des lots

```
Badge Certifié
  Fond      → #2D5016
  Texte     → #FFFFFF
  Contenu   → ✓ Certifié
  Coins     → 20px

Badge En attente
  Fond      → #D97706
  Texte     → #FFFFFF
  Contenu   → ⏳ En attente
  Coins     → 20px

Badge En transit
  Fond      → #1D4ED8
  Texte     → #FFFFFF
  Contenu   → → En transit
  Coins     → 20px
```

**CSS :**
```css
.badge {
  font-family: 'Epilogue', sans-serif;
  font-weight: 600;
  font-size: 13px;
  padding: 4px 12px;
  border-radius: 20px;
  color: #FFFFFF;
  display: inline-block;
}
.badge-certified  { background-color: #2D5016; }
.badge-pending    { background-color: #D97706; }
.badge-transit    { background-color: #1D4ED8; }
```

---

### Alerte fraude

```
Fond            → #FEF2F2
Bordure gauche  → 4px solid #DC2626
Icône           → ⚠️
Texte           → #3D1C02
Padding         → 16px
Coins           → 8px
```

---

### Bannière hors ligne

```
Fond            → #D97706
Texte           → #FFFFFF
Icône           → 📵
Message         → "Hors ligne — X enregistrement(s) en attente de synchronisation"
Position        → En haut de l'écran, apparaît uniquement si pas de connexion
```

---

### Bouton audio 🔊

```
Forme           → Rond
Taille          → 48px × 48px
Fond            → #C9933A
Icône           → micro blanc
Position        → Fixe, bas-droite, margin 24px
Ombre           → 0 4px 12px rgba(61, 28, 2, 0.25)
```

---

### Champ de saisie (Input)

```
Fond            → #FFFFFF
Bordure         → 1.5px solid #E0D5C8
Bordure focus   → 1.5px solid #C9933A
Coins           → 8px
Padding         → 14px 16px
Police          → Epilogue 400 16px
Placeholder     → #8A7A6A
Hauteur         → 56px
```

---

### Barre de progression (étapes)

```
Fond total      → #E0D5C8
Fond actif      → #C9933A
Hauteur         → 6px
Coins           → 3px
Texte étape     → Epilogue 500 14px #8A7A6A
```

---

## 6. Icônes

Utiliser **Phosphor Icons** — légères, cohérentes, open source.

- Site : https://phosphoricons.com
- CDN pour HTML : `<script src="https://unpkg.com/@phosphor-icons/web"></script>`
- Package Flutter : `phosphor_flutter` sur pub.dev

Icônes clés du projet :

```
Agriculteur     → ph-plant
Coopérative     → ph-buildings
Exportateur     → ph-ship
Certificat      → ph-certificate
QR Code         → ph-qr-code
Blockchain      → ph-link
Validation      → ph-check-circle
Alerte fraude   → ph-warning
Audio           → ph-microphone
GPS             → ph-map-pin
Lot             → ph-package
Photo           → ph-camera
```

---

## 7. Ombres et élévations

```
Élévation 1 (cartes)      → 0 2px 12px rgba(61, 28, 2, 0.10)
Élévation 2 (modals)      → 0 8px 32px rgba(61, 28, 2, 0.15)
Élévation 3 (bouton audio)→ 0 4px 12px rgba(61, 28, 2, 0.25)
```

---

## 8. Animations

```
Durée standard        → 200ms
Durée longue          → 400ms
Easing standard       → ease (entrée/sortie douce)
Easing apparition     → ease-out

Flash QR validé       → fond vert 300ms puis disparaît
Animation succès      → checkmark scale 0 → 1, 400ms ease-out
Compteurs chiffres    → count-up au scroll, 1000ms
Barre progression     → width 0 → X%, 300ms ease
```

---

## 9. Règles pour Flutter (Georges et Trésor)

Définir les couleurs dans `lib/core/theme/app_colors.dart` :

```dart
class AppColors {
  static const Color cacao      = Color(0xFF3D1C02);
  static const Color orChaud    = Color(0xFFC9933A);
  static const Color orVif      = Color(0xFFE8B04B);
  static const Color vertFeuille = Color(0xFF2D5016);
  static const Color creme      = Color(0xFFFAF6EE);
  static const Color grisTexte  = Color(0xFF8A7A6A);
  static const Color orangeAlerte = Color(0xFFD97706);
  static const Color bleuTransit = Color(0xFF1D4ED8);
  static const Color rougeErreur = Color(0xFFDC2626);
}
```

Définir les styles de texte dans `lib/core/theme/app_text_styles.dart` :

```dart
class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.cacao,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.cacao,
  );
  static const TextStyle body = TextStyle(
    fontFamily: 'Epilogue',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.cacao,
  );
  static const TextStyle bodySecondary = TextStyle(
    fontFamily: 'Epilogue',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.grisTexte,
  );
  static const TextStyle button = TextStyle(
    fontFamily: 'Epilogue',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static const TextStyle hashBlockchain = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.cacao,
  );
}
```

---

## 10. Checklist avant de pousser du code UI

Avant chaque PR qui touche à l'interface, vérifier :

- [ ] Les couleurs utilisées sont dans la palette officielle
- [ ] Les polices sont Playfair Display, Epilogue ou JetBrains Mono uniquement
- [ ] Les boutons font au moins 56px de hauteur
- [ ] Les textes font au moins 14px
- [ ] Les coins des cartes sont à 12px, les boutons à 8px
- [ ] Les badges de statut utilisent les bonnes couleurs
- [ ] Le logo n'est pas déformé ou recolorisé
- [ ] L'interface est testée sur mobile (320px minimum)

---

*ChainCacao · Equipe TG-40 · MIABE Hackathon 2026 · Lomé, Togo*
