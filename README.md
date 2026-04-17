# 🐧 Lab 2 - Script Bash : Création d'utilisateurs en masse

## Description
Script Bash permettant de créer des utilisateurs Linux en masse
à partir d'un fichier CSV, avec assignation de groupes et génération
d'un rapport de log.

## Fonctionnalités
- ✅ Lecture d'un fichier CSV (username, group, shell)
- ✅ Création automatique des groupes si inexistants
- ✅ Vérification des doublons (utilisateurs déjà existants)
- ✅ Mot de passe par défaut + obligation de changer au 1er login
- ✅ Rapport de log horodaté dans `/logs/`
- ✅ Affichage coloré dans le terminal

## Utilisation

\`\`\`bash
# 1. Modifier le fichier CSV avec tes utilisateurs
nano scripts/users.csv

# 2. Lancer le script (nécessite les droits root)
sudo bash scripts/create_users.sh
\`\`\`

## Format du fichier CSV

\`\`\`
username,group,shell
alice,developers,/bin/bash
bob,admins,/bin/bash
\`\`\`

## Exemple de rapport généré

\`\`\`
============================================
 RAPPORT DE CRÉATION D'UTILISATEURS
 Date : Thu Apr 16 12:00:00 2026
============================================
[OK] Utilisateur 'alice' créé → groupe: developers, shell: /bin/bash
[OK] Utilisateur 'bob' créé → groupe: developers, shell: /bin/bash
[IGNORÉ] L'utilisateur 'carol' existe déjà.
============================================
\`\`\`

## Compétences démontrées
- Scripting Bash avancé
- Administration système Linux (useradd, groupadd, chpasswd, chage)
- Parsing de fichiers CSV en Bash
- Gestion d'erreurs et logging
