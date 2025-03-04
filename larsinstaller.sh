#!/bin/bash

set -e

#controlla se brew è installato
if ! command -v brew &>/dev/null; then
    echo "Errore: Homebrew non è installato!"
    echo "Esegui: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

if ! command -v gh &>/dev/null; then
    echo "Installazione GitHub CLI..."
    brew install gh

    echo "Configurazione GitHub CLI..."
    gh auth login
fi

# Verifica se l'utente è loggato su GitHub
if ! gh auth status &>/dev/null; then
    echo "Errore: Devi effettuare il login su GitHub CLI."
    echo "Esegui: gh auth login"
    exit 1
fi

# Verifica se composer è installato
if ! command -v composer &>/dev/null; then
    echo "Errore: Composer non è installato!"
    echo 'Esegui: /bin/bash -c "$(curl -fsSL https://php.new/install/mac/8.4)"'
    exit 1
fi

# Verifica se npm è installato
if ! command -v npm &>/dev/null; then
    echo "Errore: npm non è installato!"
    echo "Esegui: brew install npm"
    exit 1
fi

echo "Installazione Lars..."
curl -s https://raw.githubusercontent.com/andreaterminivisia/larsinstaller/refs/heads/main/lars.sh -o lars.sh
chmod +x lars.sh
sudo mv lars.sh /usr/local/bin/lars
echo "Installazione completata!"


# output che tutto è ok
echo "Tutto è ok! Puoi chiudere il terminale"
