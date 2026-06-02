variable "aws_region" {
  description = "Region geografica de AWS donde se desplegaran todos los recursos"
  type        = string
  default     = "us-east-1"
}

variable "ssh_key_name" {
  description = "Nombre identificador de la llave SSH en la consola de AWS"
  type        = string
  default     = "VampireNightXX-key"
}

variable "ssh_key_filename" {
  description = "Nombre y ruta del archivo fisico .pem que se guardara localmente en Ubuntu"
  type        = string
  default     = "VampireNightXX-key.pem"
}

variable "tls_key_bits" {
  description = "Tamano en bits para la generacion de la llave privada RSA"
  type        = number
  default     = 4096
}

variable "vpc_name" {
  description = "Nombre asignado como etiqueta (Tag: Name) a la VPC"
  type        = string
  default     = "VampireNightXX-vpc"
}

variable "vpc_cidr_block" {
  description = "Bloque de direccionamiento IP primario para la VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "subnet_a_name" {
  description = "Nombre asignado a la Subred Publica de la zona A"
  type        = string
  default     = "VampireNightXX-subnet-a"
}

variable "subnet_a_cidr" {
  description = "Bloque de direccionamiento IP para la Subred Publica A"
  type        = string
  default     = "10.1.1.0/24"
}

variable "subnet_a_az" {
  description = "Zona de disponibilidad especifica para la Subred Publica A"
  type        = string
  default     = "us-east-1a"
}

variable "subnet_b_name" {
  description = "Nombre asignado a la Subred Publica de la zona B"
  type        = string
  default     = "VampireNightXX-subnet-b"
}

variable "subnet_b_cidr" {
  description = "Bloque de direccionamiento IP para la Subred Publica B"
  type        = string
  default     = "10.1.2.0/24"
}

variable "subnet_b_az" {
  description = "Zona de disponibilidad especifica para la Subred Publica B"
  type        = string
  default     = "us-east-1b"
}

variable "internet_gateway_name" {
  description = "Nombre asignado al Internet Gateway"
  type        = string
  default     = "VampireNightXX-igw"
}

variable "route_table_name" {
  description = "Nombre asignado a la Tabla de Enrutamiento Publica"
  type        = string
  default     = "VampireNightXX-rt"
}

variable "security_group_name" {
  description = "Nombre asignado al Security Group"
  type        = string
  default     = "VampireNightXX-sg"
}

variable "ssh_port" {
  description = "Puerto de red destinado para el trafico de administracion SSH"
  type        = number
  default     = 22
}

variable "http_port" {
  description = "Puerto de red destinado para el trafico web publico HTTP"
  type        = number
  default     = 80
}

variable "allowed_cidr_blocks" {
  description = "Lista de bloques CIDR remotos permitidos para acceder a la instancia"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ec2_instance_name" {
  description = "Nombre de la instancia de computo EC2 (Servidor Web)"
  type        = string
  default     = "VampireNightXX-ec2"
}

variable "ec2_instance_type" {
  description = "Tipo de instancia o tamano de hardware en AWS"
  type        = string
  default     = "t3.medium"
}

variable "ami_owner" {
  description = "Identificador oficial de la cuenta propietaria de la AMI"
  type        = list(string)
  default     = ["099720109477"]
}

variable "ami_name_filter" {
  description = "Patron de busqueda para localizar la AMI oficial de Ubuntu"
  type        = list(string)
  default     = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
}

variable "ssh_connect_user" {
  description = "Nombre del usuario predeterminado del sistema operativo de la AMI"
  type        = string
  default     = "ubuntu"
}

variable "s3_bucket_name" {
  description = "Nombre UNICO GLOBAL para el bucket de S3"
  type        = string
  default     = "vampirenightxx-storage-bucket-auy1105"
}

variable "s3_bucket_is_public" {
  description = "Control logico interno: determina si el bucket S3 se expone a internet"
  type        = bool
  default     = true
}

variable "s3_force_destroy" {
  description = "Permite o deniega a Terraform borrar el bucket si contiene archivos"
  type        = bool
  default     = false
}

variable "s3_versioning_status" {
  description = "Estado del control de versiones del bucket S3"
  type        = string
  default     = "Enabled"
}

variable "s3_encryption_algorithm" {
  description = "Algoritmo de cifrado del lado del servidor"
  type        = string
  default     = "AES256"
}
