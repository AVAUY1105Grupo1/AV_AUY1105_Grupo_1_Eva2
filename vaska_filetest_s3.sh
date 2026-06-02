#!/bin/bash

echo "======================================================"
echo "Iniciando prueba de carga hacia Amazon S3..."
echo "======================================================"

# Paso 1: Crea un archivo de prueba en tu maquina Ubuntu
echo "Creando el archivo local 'prueba.txt'..."
echo "Felicitaciones, este es un archivo de prueba en S3. Tu S3 esta funcionando" > prueba.txt

# Paso 2: Sube el archivo a tu Bucket S3
# IMPORTANTE: Asegurate de cambiar las 'xxxx' por el numero real de tu bucket en el comando de abajo
echo "Subiendo 'prueba.txt' al bucket S3..."
aws s3 cp prueba.txt s3://vampirenightxx-storage-bucket-xxxx/prueba.txt

echo "======================================================"
echo "Proceso finalizado. Verifica la URL publica en tu navegador!"
echo "======================================================"
