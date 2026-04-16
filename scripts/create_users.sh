#!/bin/bash

# ============================================
# Script : create_users.sh
# Description : Création d'utilisateurs Linux
#               en masse depuis un fichier CSV
# Auteur : [Ton nom]
# Date : $(date +%Y-%m-%d)
# ============================================

# --- Configuration ---
CSV_FILE="$(dirname "$0")/users.csv"
LOG_FILE="$(dirname "$0")/../logs/rapport_$(date +%Y%m%d_%H%M%S).log"
PASSWORD_DEFAULT="ChangeMe123!"

# --- Couleurs pour le terminal ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Vérification : exécuté en root ? ---
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[ERREUR] Ce script doit être exécuté en tant que root (sudo).${NC}"
   exit 1
fi

# --- Vérification : fichier CSV existe ? ---
if [[ ! -f "$CSV_FILE" ]]; then
    echo -e "${RED}[ERREUR] Fichier CSV introuvable : $CSV_FILE${NC}"
    exit 1
fi

# --- Initialisation du rapport ---
mkdir -p "$(dirname "$LOG_FILE")"
echo "============================================" | tee "$LOG_FILE"
echo " RAPPORT DE CRÉATION D'UTILISATEURS"        | tee -a "$LOG_FILE"
echo " Date : $(date)"                             | tee -a "$LOG_FILE"
echo "============================================" | tee -a "$LOG_FILE"

CREATED=0
SKIPPED=0
ERRORS=0

# --- Lecture du CSV (on saute la première ligne = entête) ---
tail -n +2 "$CSV_FILE" | while IFS=',' read -r username group shell; do

    # Nettoyer les espaces éventuels
    username=$(echo "$username" | xargs)
    group=$(echo "$group" | xargs)
    shell=$(echo "$shell" | xargs)

    echo -e "\n[INFO] Traitement de l'utilisateur : $username" | tee -a "$LOG_FILE"

    # Vérifier si l'utilisateur existe déjà
    if id "$username" &>/dev/null; then
        echo -e "${YELLOW}[IGNORÉ] L'utilisateur '$username' existe déjà.${NC}" | tee -a "$LOG_FILE"
        ((SKIPPED++))
        continue
    fi

    # Créer le groupe s'il n'existe pas
    if ! getent group "$group" &>/dev/null; then
        groupadd "$group"
        echo -e "[INFO] Groupe '$group' créé." | tee -a "$LOG_FILE"
    fi

    # Créer l'utilisateur
    if useradd -m -s "$shell" -g "$group" "$username"; then
        # Définir le mot de passe par défaut
        echo "$username:$PASSWORD_DEFAULT" | chpasswd
        # Forcer le changement de mot de passe à la première connexion
        chage -d 0 "$username"

        echo -e "${GREEN}[OK] Utilisateur '$username' créé → groupe: $group, shell: $shell${NC}" | tee -a "$LOG_FILE"
        ((CREATED++))
    else
        echo -e "${RED}[ERREUR] Impossible de créer '$username'.${NC}" | tee -a "$LOG_FILE"
        ((ERRORS++))
    fi

done

# --- Résumé final ---
echo -e "\n============================================" | tee -a "$LOG_FILE"
echo " RÉSUMÉ"                                          | tee -a "$LOG_FILE"
echo "============================================"      | tee -a "$LOG_FILE"
echo " ✅ Créés   : $CREATED"                           | tee -a "$LOG_FILE"
echo " ⏭️  Ignorés : $SKIPPED"                          | tee -a "$LOG_FILE"
echo " ❌ Erreurs : $ERRORS"                            | tee -a "$LOG_FILE"
echo " 📄 Rapport sauvegardé dans : $LOG_FILE"          | tee -a "$LOG_FILE"
echo "============================================"      | tee -a "$LOG_FILE"
