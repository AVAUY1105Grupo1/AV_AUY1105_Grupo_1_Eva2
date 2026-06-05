```hcl
# Invocamos el orquestador principal ubicado en la raíz del repositorio
module "arquitectura_completa" {
  source = "../../"

  # Sobrescribimos algunas variables por defecto para este entorno específico
  vpc_name          = var.custom_vpc_name
  ec2_instance_name = var.custom_ec2_name
  s3_bucket_name    = var.custom_bucket_name
}

variable "custom_vpc_name" { type = string }
variable "custom_ec2_name" { type = string }
variable "custom_bucket_name" { type = string }
