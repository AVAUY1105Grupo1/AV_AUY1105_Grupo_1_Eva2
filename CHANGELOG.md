```markdown
# Changelog

Todos los cambios notables de este orquestador principal se registran en este archivo siguiendo los estándares de [Semantic Versioning](https://semver.org/lang/es/).

## [1.0.0] - 2026-06-04
### Añadido
- Creación de la estructura central de orquestación (Root Module).
- Integración del bloque `module "networking"` apuntando al repositorio remoto de VPC, enviando los bloques CIDR y nombres de variables.
- Integración del bloque `module "compute"` apuntando al repositorio remoto de EC2, mapeando dependencias explícitas (`module.networking.subnet_public_a_id` y `module.networking.security_group_id`).
- Integración del bloque `module "storage"` apuntando al repositorio remoto de S3.
- Centralización de todas las variables en `variables.tf` bajo la nomenclatura y estándares del proyecto (`VampireNightXX`).
- Inclusión del directorio `examples/` con un entorno práctico de ejecución.
