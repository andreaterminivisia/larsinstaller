#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "Errore: Devi specificare il nome del progetto."
    echo "Uso: lars nomeprogetto"
    exit 1
fi

PROJECT_NAME="$1"

# Verifica se l'utente è loggato su GitHub
if ! gh auth status &>/dev/null; then
    echo "Errore: Devi effettuare il login su GitHub CLI."
    echo "Esegui: gh auth login"
    exit 1
fi

GITHUB_USER=$(gh auth status 2>/dev/null | awk '/Logged/ {print $7}')

echo "Avvio setup per il progetto: $PROJECT_NAME"
if [ -d "$PROJECT_NAME" ]; then
    echo "Errore: La cartella '$PROJECT_NAME' esiste già!"
    exit 1
fi
git clone git@github.com:visiaquantum/lars.git $PROJECT_NAME
cd "$PROJECT_NAME"
echo "Repository LARS clonata con successo!"

echo "Installazione delle dipendenze..."

composer install

cp .env.example .env
sed -i '' "s/APP_NAME=Laravel/APP_NAME=$PROJECT_NAME/g" .env

php artisan migrate --force

php artisan key:generate
php artisan passport:client --password --no-interaction > passport_client.txt

CLIENT_ID=$(grep "Client ID" passport_client.txt | awk '{print $NF}')
CLIENT_SECRET=$(grep "Client secret" passport_client.txt | awk '{print $NF}')

sed -i '' "/PASSPORT_PERSONAL_ACCESS_CLIENT_ID=/c\\
PASSPORT_PERSONAL_ACCESS_CLIENT_ID=${CLIENT_ID}" .env

sed -i '' "/PASSPORT_PERSONAL_ACCESS_CLIENT_SECRET=/c\\
PASSPORT_PERSONAL_ACCESS_CLIENT_SECRET=${CLIENT_SECRET}" .env

php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

npm install

echo "Dipendenze installate e migrazioni eseguite!"


echo "Creazione della repository su GitHub..."
if gh repo view "$PROJECT_NAME" &>/dev/null; then
    echo "Errore: La repository '$PROJECT_NAME' esiste già su GitHub!"
else
    git init
    gh repo create "$PROJECT_NAME" --private --source=. --remote=upstream --push
    echo "Repository creata con successo!"
fi

echo "Setup completato con successo!"
