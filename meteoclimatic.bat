@echo off


REM Este script envía los datos meteorológicos de una estación meteorológica a Meteoclimatic y utiliza la API V3 de Meteoclimatic-Alba
REM 
REM El script está preparado para buscar el fichero meteoclimatic.htm en el mismo directorio donde se encuentre ubicado el Script.
REM 
REM ##########################################################################################################
REM ## SOLO TIENES QUE CONFIGURAR LA APIKEY DE TU ESTACIÓN. ESCRÍBELA SIN COMILLAS A PARTIR DEL SIGNO IGUAL ##
REM ##########################################################################################################

REM La apikey la encontrarás en tu perfil de Meteoclimatic, bajo el nombre "Identificador de API"



set apikey=




rem #########################################################
rem ########   NO MODIFICAR NADA A PARTIR DE AQUI   #########
rem #########################################################

setlocal

:loop

rem Obtiene la ruta del directorio actual del script
for %%I in (%0) do set "script_dir=%%~dpI"

rem Define la ruta del archivo meteoclimatic.htm
set "datafile=%script_dir%meteoclimatic.htm"

rem Define el archivo de log
set "logfile=%script_dir%envios.log"

rem Comprueba si el archivo meteoclimatic.htm existe
if not exist "%datafile%" (
    echo [%date% %time%] El archivo meteoclimatic.htm no existe en "%script_dir%". >> "%logfile%"
    echo El archivo meteoclimatic.htm no existe en "%script_dir%".
    exit /b 1
)

rem Lee el archivo meteoclimatic.htm y extrae el codigo de la estacion
for /F "tokens=2 delims==" %%A in ('type "%datafile%" ^| findstr /C:"*COD="') do set "stationcode=%%A"

rem Comprueba si se ha encontrado el codigo de la estacion
if "%stationcode%"=="" (
    echo [%date% %time%] No se ha encontrado el codigo de la estacion en el archivo. >> "%logfile%"
    echo No se ha encontrado el codigo de la estacion en el archivo.
    exit /b 1
)

rem Define las variables para la comando curl
set url=https://api.m11c.net/v3/station/wxupdate
set resposta=%script_dir%resposta.txt

rem Envía la solicitud con cURL
curl --data-urlencode "stationcode=%stationcode%" --data-urlencode "rawData2@%datafile%" -H "APIkey: %apikey%" -X POST -k -o "%resposta%" "%url%"

rem Comprueba si la ejecucion fue correcta
if %errorlevel% neq 0 (
    echo [%date% %time%] Error en la ejecucion de la solicitud. >> "%logfile%"
    echo Error en la ejecucion de la solicitud.
    exit /b 1
)

rem Mostrar resultado en pantalla
echo ===============================
echo Respuesta del servidor:
type "%resposta%"
echo ===============================

rem Espera 5 minutos antes de repetir el bucle
ping -n 301 127.0.0.1 >nul

goto :loop

endlocal
