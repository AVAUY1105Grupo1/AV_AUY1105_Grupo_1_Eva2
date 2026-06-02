output "vpc_id" {
  description = "ID de la VPC principal desplegada"
  value       = module.networking.vpc_id
}

output "subnet_ids" {
  description = "Lista de las IDs de las subredes publicas aprovisionadas"
  value       = module.networking.subnet_ids
}

output "instance_id" {
  description = "ID de la instancia Web EC2"
  value       = module.compute.instance_id
}

output "instance_ip" {
  description = "Direccion IP publica para el acceso SSH al servidor"
  value       = module.compute.instance_ip
}

output "website_url" {
  description = "Enlace directo para validar el Apache funcionando en el navegador"
  value       = "http://${module.compute.instance_ip}"
}

output "s3_bucket_name" {
  description = "Nombre unico creado en AWS S3"
  value       = module.storage.s3_bucket_name
}

output "s3_bucket_url" {
  description = "Enlace base nativo de Amazon S3"
  value       = module.storage.s3_bucket_url
}
