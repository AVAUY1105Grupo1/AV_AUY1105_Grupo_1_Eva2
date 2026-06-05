# Ejemplos de Configuración del Orquestador

## Objetivo del ejemplo
Esta carpeta demuestra cómo utilizar el repositorio orquestador principal inyectando valores personalizados mediante un archivo de variables (`.tfvars`). Esto permite reutilizar esta misma arquitectura central para desplegar múltiples entornos (ej. Desarrollo, QA, Producción) sin modificar el código base.

## Instrucciones de uso
1. Navega al directorio del ejemplo:
   ```bash
   cd examples/despliegue_entorno_custom
2. Inicializa Terraform y ejecuta el plan pasando el archivo de variables:
   ```bash
   terraform init
   terraform plan -var-file="custom.tfvars"
