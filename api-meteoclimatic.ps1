# Creado a partir del script original de jantoni (Abril 2026)

# Debes asegurarte que Powershell está habilitado para ejecutar scripts.
# Ejecuta este comando dentro de Powershell
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Ejecuta el comando manualmente para asegurarte que funciona. Sitúate en el directorio donde se encuentra el script y ejecuta:
# .\api-meteoclimatic.ps1
# Si todo funciona correctamente, verás un mensaje con el estado 200  @{status=queued for update}

# Para activar el comando cada 5 minutos, puedes utilizar el siguiente comando dentro de una ventana Powershell
# schtasks /create /sc minute /mo 5 /tn "Meteoclimatic" /tr "powershell.exe -ExecutionPolicy Bypass -File C:\ruta\api-meteoclimatic.ps1"

# Configuración
# Debes modificar la ruta donde se encuentra el Script.
# Tan solo tienes que definir las siguientes variables:
# RETRASO es el número de segundos que quieres que el script se pare antes de enviar datos a Meteoclimatic. Ajústalo en función
# del tiempo que tarde tu software en generar ficheros para evitar enviar datos atrasados. 50 es una buena cifra para empezar
# API_KEY define el ID API (o API Key) del usuario, no de la estación. Lo puedes encontrar en la sección "Perfil" de Meteoclimatic una vez identificado
# DATAFILE define el fichero donde este script debe encontrar los datos a enviar a Meteoclimatic. Debes indicar la ruta y el nombre del fichero



# VARIABLES A DEFINIR
$RETRASO = 50
$API_KEY = "TU_API_KEY"
$DATAFILE = "C:\ruta\al\fichero.txt"

####################################
## NO TOCAR NADA A PARTIR DE AQUÍ ##
####################################

Start-Sleep -Seconds $RETRASO

$URL = "https://api.m11c.net/v3/station/wxupdate"

# Comprobar fichero
if (!(Test-Path $DATAFILE)) {
    Write-Host "Error: no existe el fichero $DATAFILE"
    exit 1
}

$POST_DATA = ""
$STATION_CODE = ""

# Leer fichero
Get-Content $DATAFILE | ForEach-Object {
    $linea = $_.Trim()

    # Ignorar vacías o fin
    if ([string]::IsNullOrWhiteSpace($linea) -or $linea -eq "*EOT*") {
        return
    }

    # Quitar *
    if ($linea.StartsWith("*")) {
        $linea = $linea.Substring(1)
    }

    # Separar clave=valor
    if ($linea -match "=") {
        $partes = $linea -split "=", 2
        $clave = $partes[0].Trim()
        $valor = $partes[1].Trim()

        # Capturar COD
        if ($clave -eq "COD") {
            $STATION_CODE = $valor
            return
        }

        # Ignorar vacíos
        if ([string]::IsNullOrWhiteSpace($valor)) {
            return
        }

        $POST_DATA += "&$clave=$valor"
    }
}

# Validar station code
if ([string]::IsNullOrWhiteSpace($STATION_CODE)) {
    Write-Host "Error: no se encontró COD"
    exit 1
}

# Añadir stationcode al body
$POST_DATA = "stationcode=$STATION_CODE$POST_DATA"

# Enviar POST
Invoke-RestMethod -Uri $URL `
    -Method POST `
    -Headers @{ "APIkey" = $API_KEY } `
    -Body $POST_DATA `
    -ContentType "application/x-www-form-urlencoded"
    
