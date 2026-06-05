# Orquestador Principal de Infraestructura AWS - Grupo 1

## Objetivos del repositorio
Este repositorio cumple la función de controlador central (Root Module) para la evaluación. Su objetivo fundamental es estructurar el despliegue de la infraestructura mediante la integración y el llamado coordinado de los módulos independientes alojados en repositorios remotos de GitHub (Redes, Cómputo y Almacenamiento). 

## Propósito general del código Terraform
Este código actúa como el punto de orquestación único. Al ejecutar este repositorio, Terraform descarga dinámicamente los módulos externos y aprovisiona:
1. **Infraestructura de Red:** Utiliza el submódulo de redes para crear una VPC, subredes públicas distribuidas (A y B), Internet Gateway, tablas de enrutamiento y un Security Group web.
2. **Recursos de Cómputo:** Consume el ID de la subred pública A y el Security Group generados en el paso anterior para instanciar un servidor web EC2 (Ubuntu 24.04), gestionando automáticamente la creación de credenciales RSA (`VampireNightXX-key.pem`).
3. **Almacenamiento S3:** Invoca el submódulo de almacenamiento para crear un bucket con versionado, cifrado AES256 y políticas de acceso público configurables.

## Instrucciones básicas de uso

### Requisitos previos
* Terraform instalado (versión `>= 1.0.0`).
* Credenciales de AWS configuradas en el entorno local (`aws configure`).
* Git instalado para permitir que Terraform clone los submódulos desde los repositorios remotos.

### Flujo de despliegue automatizado
Para levantar toda la arquitectura de una sola vez, ejecuta los siguientes comandos en la raíz del repositorio:

1. **Inicialización:** (Descarga los módulos desde las URLs de Git definidas en `main.tf`)
   ```bash
   terraform init
2. **Validación:**
   ```bash
   terraform validate
3. **Planificación:**
   ```bash
   terraform plan
5. **Aplicación:**
   ```bash
   terraform apply
    ```
## Variables de Entrada (Inputs Centralizados)
Toda la infraestructura se parametriza de forma centralizada en este repositorio. Las variables principales (definidas en variables.tf) incluyen:

Globales y Redes:

* aws_region: Región de despliegue (defecto: us-east-1).

* vpc_name / vpc_cidr_block: Nombre y CIDR de la VPC.

* subnet_a_cidr / subnet_b_cidr: Direccionamiento para las subredes públicas.

* ssh_port / http_port: Puertos habilitados en el grupo de seguridad (22 y 80).

Cómputo:

* ec2_instance_type: Tamaño de la instancia (defecto: t3.medium).

* ssh_key_name / ssh_key_filename: Nombres para el registro de la llave en AWS y el archivo .pem local.

* ami_name_filter: Filtro para localizar la imagen de Ubuntu 24.04.

Almacenamiento:

* s3_bucket_name: Nombre único global para el bucket.

* s3_bucket_is_public: Interruptor de seguridad (true para acceso público).
