#!/bin/bash

# Vérification des privilèges root
if [ "$EUID" -ne 0 ]; then
    echo "Veuillez exécuter ce script avec des privilèges root (sudo)."
    exit 1
fi

echo "Mise à jour du système..."
dnf update -y

echo "Installation des dépendances nécessaires..."
dnf install -y perl-App-cpanminus perl-AnyEvent-AIO perl-Coro perl-Moose \
    perl-PadWalker perl-JSON perl-IO-AIO perl-Data-Dump perl-devel gcc make

echo "Installation des modules CPAN requis..."
cpanm Class::Refresh
cpanm Compiler::Lexer
cpanm Hash::SafeKeys
cpanm Perl::LanguageServer

echo "Vérification de l'installation de Perl::LanguageServer..."
if perl -MPerl::LanguageServer -e 'print "Perl::LanguageServer installé avec succès\n";'; then
    echo "Perl::LanguageServer est installé correctement."
else
    echo "Échec de l'installation de Perl::LanguageServer."
    exit 1
fi

# Configuration de Visual Studio Code
VSCODE_SETTINGS_DIR="$HOME/.config/Code/User"
SETTINGS_FILE="$VSCODE_SETTINGS_DIR/settings.json"

echo "Configuration des paramètres pour Visual Studio Code..."
mkdir -p "$VSCODE_SETTINGS_DIR"
if [ -f "$SETTINGS_FILE" ]; then
    echo "Fichier settings.json trouvé, mise à jour..."
else
    echo "Création d'un nouveau fichier settings.json..."
    touch "$SETTINGS_FILE"
fi

# Ajout des paramètres à settings.json
cat <<EOL > "$SETTINGS_FILE"
{
    "perl.enable": true,
    "perl.perlCmd": "perl",
    "perl.perlInc": [
        "/usr/local/share/perl5",
        "/usr/share/perl5"
    ],
    "perl.fileFilter": [".pl", ".pm"],
    "perl.ignoreDirs": [".vscode", ".git"],
    "perl.logLevel": 1
}
EOL

echo "Configuration terminée pour Visual Studio Code."

# Résumé
echo "--------------------------------------------"
echo "Perl::LanguageServer et ses dépendances ont été installés."
echo "Visual Studio Code a été configuré pour le support de Perl."
echo "Vous pouvez maintenant redémarrer VSCode pour utiliser Perl::LanguageServer."
echo "--------------------------------------------"
