# API_V3
Ficheros, scripts y otros correspondientes a la Versión 3 de la API Meteoclimatic

Rutinas para el envío de datos a Meteoclimatic via API

api-meteoclimatic.py es una rutina en Python para enviar los datos de tu estación meteorológica a Meteoclimatic mediante la API de Meteoclimatic. Funciona con los códigos de estación y apikey de Alba Información dentro del propio script.

api-meteoclimatic.sh es una rutina en Bash para enviar datos de tu estación meteorológica a Meteoclimatic mediante la API de Meteoclimatic. Funciona con los códigos de estación y apikey de Alba Los datos a configurar los encontrarás dentro del propio script.

api-meteoclimatic.bat es un fichero de lotes para Windows. Utiliza la API V3 de Meeoclimatic. Solo tendrás que configurar la APIkey de Meteoclimatic. Los demás datos, como el código de estación, son obtenidos directamente del fichero meteoclimatic.htm que debe generar tu software (Cumulus, CumulusMX, Weewx, WeatherDisplay, Weatherlink, etc)

dayfile-%Y-%m.txt.tmpl es una plantilla para instalarla en un skin de Weewx. Genera un fichero dayfile.txt por cada mes que haya almacenado en la base de datos Este informe sirve para subir datos que falten en Meteoclimatic y los tengamos en nuestra base de datos. Basado en los informes NOAA de Tom Keffer
