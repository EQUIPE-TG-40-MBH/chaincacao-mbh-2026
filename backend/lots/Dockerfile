# Utilisation d'une image Python légère
FROM python:3.11-slim

# Variables d'environnement pour Python
ENV PYTHONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Répertoire de travail
WORKDIR /app

# Installation des dépendances système (nécessaires pour psycopg2)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Installation des dépendances Python
COPY requirements.txt /app/
RUN pip install --upgrade pip && pip install -r requirements.txt
RUN pip install gunicorn

# Copie du code source
COPY . /app/

# Collecte des fichiers statiques
RUN python manage.py collectstatic --noinput

# Port exposé
EXPOSE 8000

# Commande de démarrage
CMD gunicorn chaincacao.wsgi:application --bind 0.0.0.0:$PORT