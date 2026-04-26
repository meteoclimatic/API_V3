#!/usr/bin/python3
# -*- coding: utf-8 -*-

# Creado por José A. García-Tenorio (jantoni) en Abril de 2026

# Este Script envía los datos de tu estación a Meteoclimatic utilizando la versión 3 de su API.
# Para ello necesitas definir 2 variables
# - api_key define el ID API (o API Key) del usuario, no de la estación. Lo puedes encontrar en la sección "Perfil" de Meteoclimatic una vez identificado
# - datafile define el fichero donde este script debe encontrar los datos a enviar a Meteoclimatic. Debes indicar la ruta y el nombre del fichero
#
# Para que funcione este script necesitas darle permisos de ejecución con chmod o bien invocarlo con el comando python3
# sudo python3 /etc/weewx/api-meteoclimatic.py
# 
# Para que envíe datos regularmente deberás añadir una línea al fichero /etc/crontab (o al fichero de cron que elijas)
# Recomendamos enviar datos cada 5 minutos, por lo que la línea de /etc/crontab quedaría así:
# */5 * * * * root sleep 50 && python3 /etc/weewx/api-meteoclimatic.py
# Explicación: Ejecuta cada 5 minutos el comando sleep 50, lo que provoca un retraso de 50 segundos para que la generación del fichero
# con los datos sea finalizado por tu software. A continuación de los 50 segundos ejecuta el script.


###########################
### VARIABLES A DEFINIR ###
###########################

# Tu apikey Meteoclimatic. Podrás verlo en tu perfil, con el nombre "Identificador de API"
api_key = "TU_API_KEY"

# La ruta y el nombre del fichero que contiene los datos
datafile = "PATH_Y_NOMBRE_FICHERO_DATOS"


############################################
### A PARTIR DE AQUÍ NO DEBES TOCAR NADA ###
############################################

url = "https://api.m11c.net/v3/station/wxupdate"

import requests
import json

datos = {}
station_code = None

# Leer fichero e incorporar cada variable para luego enviarlo en el POST
with open(datafile, "r") as f:
    for linea in f:
        linea = linea.strip()

        if not linea or linea == "*EOT*":
            continue

        if linea.startswith("*"):
            linea = linea[1:]

        if "=" in linea:
            clave, valor = linea.split("=", 1)
            clave = clave.strip()
            valor = valor.strip()

            # Capturar COD
            if clave == "COD":
                station_code = valor
                continue

            # Ignorar vacíos
            if valor == "":
                continue

            datos[clave] = valor

# Validación
if not station_code:
    print("Error: no se encontró COD en el fichero")
    exit(1)

# 👉 Añadir stationCode también al body
datos["stationcode"] = station_code

# Cabeceras
cabeceras = {
    "APIkey": api_key
}

# Debug opcional
# print(json.dumps(datos, indent=2))

# Envío
response = requests.post(url, headers=cabeceras, data=datos, timeout=5)

# Muestra la respuesta de Meteoclimatic y los datos enviados (SOLO PARA PRUEBAS)
# print(response.text)
# print (datos)

# Control de respuesta
if response.status_code == 200:
    response_data = json.loads(response.text)

    if "fault" in response_data:
        fault_code = response_data["fault"]["code"]
        fault_status = response_data["fault"]["status"]
        print(f"{fault_code} - {fault_status}")
else:
    print("Error:", response.status_code)
