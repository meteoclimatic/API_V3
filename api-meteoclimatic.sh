#!/bin/bash

# Creado por José A. García-Tenorio (jantoni) en Abril de 2026

# Este Script para Bash envía los datos de tu estación a Meteoclimatic utilizando la versión 3 de su API.
# Para ello necesitas definir 2 variables
# - api_key define el ID API (o API Key) del usuario, no de la estación. Lo puedes encontrar en la sección "Perfil" de Meteoclimatic una vez identificado
# - datafile define el fichero donde este script debe encontrar los datos a enviar a Meteoclimatic. Debes indicar la ruta y el nombre del fichero
#
# Para que funcione este script necesitas darle permisos de ejecución con chmod o bien invocarlo con el comando bash
# sudo bash /etc/weewx/api-meteoclimatic.sh
# 
# Para que envíe datos regularmente deberás añadir una línea al fichero /etc/crontab (o al fichero de cron que elijas)
# Recomendamos enviar datos cada 5 minutos, por lo que la línea de /etc/crontab quedaría así:
# */5 * * * * root sleep 50 && bash /etc/weewx/api-meteoclimatic.sh
# Explicación: Ejecuta cada 5 minutos el comando sleep 50, lo que provoca un retraso de 50 segundos para que la generación del fichero
# con los datos sea finalizado por tu software. A continuación de los 50 segundos ejecuta el script.

# IMPORTANTE: Si tu sistema operativo no utilza bash, deberás utilizar otro intérprete de comandos como sh, csh, zsh, etc.
# La adaptación a otro intérprete de comandos corre por tu cuenta.


### VARIABLES A DEFINIR ###
API_KEY="TU_API_KEY"
DATAFILE="PATH_Y_NOMBRE_FICHERO_DATOS"



##################################
# NO TOCAR NADA A PARTIR DE AQUÍ #
##################################

URL="https://api.m11c.net/v3/station/wxupdate"

# Comprobar fichero
if [ ! -f "$DATAFILE" ]; then
    echo "Error: no existe el fichero $DATAFILE"
    exit 1
fi

POST_DATA=""
STATION_CODE=""

# Leer fichero
while IFS= read -r linea; do
    linea=$(echo "$linea" | tr -d '\r\n')

    # Ignorar vacías o fin
    [[ -z "$linea" || "$linea" == "*EOT*" ]] && continue

    # Quitar *
    linea="${linea#\*}"

    # Separar clave=valor
    if [[ "$linea" == *"="* ]]; then
        clave="${linea%%=*}"
        valor="${linea#*=}"

        clave=$(echo "$clave" | xargs)
        valor=$(echo "$valor" | xargs)

        # Capturar COD
        if [[ "$clave" == "COD" ]]; then
            STATION_CODE="$valor"
            continue
        fi

        # Ignorar vacíos
        [[ -z "$valor" ]] && continue

        # (Opcional) ignorar N/A
        # [[ "$valor" == "N/A" ]] && continue

        POST_DATA="${POST_DATA}&${clave}=${valor}"
    fi

done < "$DATAFILE"

# Validar station code
if [ -z "$STATION_CODE" ]; then
    echo "Error: no se encontró COD"
    exit 1
fi

# Añadir stationCode al body
POST_DATA="stationcode=${STATION_CODE}${POST_DATA}"

# Enviar POST
curl -s -X POST "$URL" \
  -H "APIkey: $API_KEY" \
  -d "$POST_DATA"
