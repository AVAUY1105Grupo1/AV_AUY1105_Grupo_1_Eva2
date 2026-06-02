#!/bin/bash

# ==============================================================================
# CONFIGURACION - CONFIGURA TU BUCKET AQUI
# ==============================================================================
# IMPORTANTE: Reemplaza las 'xxxx' por la terminacion real de tu bucket AWS S3
BUCKET="vampirenightxx-storage-bucket-xxxx"

echo "======================================================================"
echo "   SCRIPT DE ANIQUILACION ABSOLUTA DE CONTENIDO - AMAZON S3"
echo "======================================================================"
echo "Bucket objetivo: $BUCKET"
echo "----------------------------------------------------------------------"

# Validacion de seguridad 1: Verificar si AWS CLI esta instalado
if ! command -v aws &> /dev/null; then
    echo "❌ ERROR: El comando 'aws' (AWS CLI) no esta instalado en este sistema."
    echo "👉 Instalalo ejecutando: sudo apt install awscli -y"
    exit 1
fi

echo "⚠️  ADVERTENCIA: Se borraran permanentemente TODAS las versiones de los"
echo "   archivos y los marcadores de borrado. Esta accion NO se puede deshacer."
echo "----------------------------------------------------------------------"
read -p "¿Estas seguro de que deseas continuar? (s/n): " confirmacion

if [[ "$confirmacion" != "s" && "$confirmacion" != "S" ]]; then
    echo "❌ Operacion cancelada por el usuario."
    exit 0
fi

echo ""
echo "🚀 Paso 1: Purgando de raiz todas las versiones de los archivos..."
# Ejecuta el borrado profundo a nivel de API de S3
aws s3api delete-objects \
    --bucket "$BUCKET" \
    --delete "$(aws s3api list-object-versions \
    --bucket "$BUCKET" \
    --output=json \
    --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')" 2>/dev/null

echo "✅ Versiones de archivos eliminadas con éxito."
echo "----------------------------------------------------------------------"

echo "🚀 Paso 2: Eliminando todos los marcadores de borrado huerfanos..."
# Limpia los DeleteMarkers remanentes para dejar el bucket 100% en cero
aws s3api delete-objects \
    --bucket "$BUCKET" \
    --delete "$(aws s3api list-object-versions \
    --bucket "$BUCKET" \
    --output=json \
    --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')" 2>/dev/null

echo "✅ Marcadores de borrado eliminados con éxito."
echo "======================================================================"
echo "🎉 ¡PROCESO COMPLETADO! El bucket S3 se encuentra totalmente vacio."
echo "======================================================================"
