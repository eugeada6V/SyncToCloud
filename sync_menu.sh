#!/bin/bash

# Definizione dei colori
GREEN='\033[1;32m'  # Verde brillante
CYAN='\033[1;36m'   # Ciano
WHITE='\033[1;37m'  # Bianco
NC='\033[0m'        # Nessun colore (reset)

# Percorso base delle cartelle locali
BASE_DIR="/media/eugenio/ESTERNO/" # Percorso locale aggiornato
declare -A FOLDERS=(
    [1]="01 Importanti"
    [2]="02 Software"
    [3]="03 Google Foto"
    [4]="04 Documenti"
    [5]="05 Archivio"
    [6]="06 Musica"
)

# Cloud remoti configurati in rclone (MyKdrive è stato rimosso)
declare -A CLOUDS=(
    [1]="Il mio Drive"
    [2]="MyBackblaze"
    [3]="MyPcloud"
)

# Nome del bucket per MyBackblaze
BACKBLAZE_BUCKET="NEWDell27"

# Funzione per visualizzare il menù delle cartelle
function show_folder_menu() {
    echo -e "${CYAN}Seleziona la cartella da sincronizzare:${NC}"
    for key in "${!FOLDERS[@]}"; do
        echo -e "${WHITE}$key) ${FOLDERS[$key]}${NC}"
    done
    echo -e "${WHITE}7) Esci${NC}"
}

# Funzione per visualizzare il menù dei cloud remoti
function show_cloud_menu() {
    echo -e "${CYAN}Seleziona il cloud remoto su cui sincronizzare:${NC}"
    for key in "${!CLOUDS[@]}"; do
        echo -e "${WHITE}$key) ${CLOUDS[$key]}${NC}"
    done
}

# Funzione per sincronizzare una cartella con un cloud remoto
function sync_folder() {
    local folder=$1
    local cloud=$2
    local remote_path=""

    # Configura il percorso remoto in base al cloud scelto
    if [[ "$cloud" == "MyBackblaze" ]]; then
        remote_path="$cloud:$BACKBLAZE_BUCKET/$folder"
    else
        remote_path="$cloud:$folder"
    fi

    echo -e "${CYAN}Sincronizzazione della cartella '$folder' con il remoto '$remote_path'...${NC}"
    rclone sync "$BASE_DIR/$folder" "$remote_path" --progress

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Sincronizzazione completata con successo!${NC}"
    else
        echo -e "${RED}Errore durante la sincronizzazione.${NC}"
    fi
}

# Ciclo del menù interattivo
while true; do
    show_folder_menu
    read -p "$(echo -e ${CYAN}Inserisci il numero della cartella da sincronizzare:${NC} ) " folder_choice

    if [[ $folder_choice -eq 7 ]]; then
        echo -e "${GREEN}Uscita dal programma. Arrivederci!${NC}"
        break
    elif [[ -n "${FOLDERS[$folder_choice]}" ]]; then
        selected_folder="${FOLDERS[$folder_choice]}"
        echo -e "${CYAN}Hai selezionato la cartella: ${WHITE}$selected_folder${NC}"

        # Mostra il menù dei cloud remoti
        show_cloud_menu
        read -p "$(echo -e ${CYAN}Inserisci il numero del cloud remoto:${NC} ) " cloud_choice

        if [[ -n "${CLOUDS[$cloud_choice]}" ]]; then
            selected_cloud="${CLOUDS[$cloud_choice]}"
            echo -e "${CYAN}Hai selezionato il cloud remoto: ${WHITE}$selected_cloud${NC}"

            # Esegui la sincronizzazione
            sync_folder "$selected_folder" "$selected_cloud"
        else
            echo -e "${RED}Scelta del cloud remoto non valida. Riprova.${NC}"
        fi
    else
        echo -e "${RED}Scelta della cartella non valida. Riprova.${NC}"
    fi

    echo # Riga vuota per separare le iterazioni
done
