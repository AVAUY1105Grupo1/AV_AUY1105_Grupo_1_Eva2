###############################################################################
# CONFIGURACION GENERAL Y PROVEEDORES
###############################################################################

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "aws" {
  region = var.aws_region 
}

###############################################################################
# BLOQUE 1 - LLAVES SSH DE ACCESO SEGURO
###############################################################################

resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = var.tls_key_bits 
}

resource "aws_key_pair" "deployer_key" {
  key_name   = var.ssh_key_name 
  public_key = tls_private_key.rsa_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.rsa_key.private_key_pem
  filename        = var.ssh_key_filename 
  file_permission = "0400"
}

###############################################################################
# BLOQUE 2 - ARQUITECTURA DE RED (NETWORKING)
###############################################################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block 
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name 
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_a_cidr 
  availability_zone       = var.subnet_a_az   
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet_a_name 
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_b_cidr 
  availability_zone       = var.subnet_b_az   
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet_b_name 
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.internet_gateway_name 
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = var.route_table_name 
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

###############################################################################
# BLOQUE 3 - CORTAFUEGOS (SECURITY GROUPS)
###############################################################################

resource "aws_security_group" "web" {
  name        = var.security_group_name 
  description = "Reglas de control de trafico para servidores web de produccion"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Permitir SSH seguro"
    from_port   = var.ssh_port 
    to_port     = var.ssh_port 
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks 
  }

  ingress {
    description = "Permitir HTTP web publico"
    from_port   = var.http_port 
    to_port     = var.http_port 
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name 
  }
}

###############################################################################
# BLOQUE 4 - RECURSOS DE COMPUTO (EC2)
###############################################################################

data "aws_ami" "ubuntu_24_04" {
  most_recent = true
  owners      = var.ami_owner 

  filter {
    name   = "name"
    values = var.ami_name_filter 
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu_24_04.id
  instance_type          = var.ec2_instance_type 
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = aws_key_pair.deployer_key.key_name

  tags = {
    Name = var.ec2_instance_name 
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y apache2",
      "sudo systemctl enable apache2",
      "sudo systemctl start apache2",
      <<-SCRIPT
      sudo tee /var/www/html/index.html > /dev/null << 'EOF'
      <!doctype html>
      <html lang="es">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width,initial-scale=1" />
        <title>VampireNightXX - Vaska HTML Simple Test File.</title>
        <style>
          :root{
            --bg-color: #000000;
            --header-color: #FF00FF; /* fuccia */
            --text-color: #FFFFFF;
          }
          html, body {
            height: 100%;
            margin: 0;
            padding: 0;
            background: var(--bg-color);
            color: var(--text-color);
            font-family: Arial, Helvetica, sans-serif;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
          }

          .container{
            min-height:100%;
            display:flex;
            flex-direction:column;
            align-items:center;
            justify-content:space-between;
            padding:40px 20px;
            box-sizing:border-box;
          }

          header{
            width:100%;
            text-align:center;
            margin-top:10px;
          }
          header h1{
            font-size:36px;
            color:var(--header-color);
            margin:0;
            line-height:1.2;
            font-weight:700;
          }

          main{
            flex:1 0 auto;
            display:flex;
            align-items:center;
            justify-content:center;
            width:100%;
            padding:40px 20px;
            box-sizing:border-box;
          }
          main p{
            font-size:26px;
            color:var(--text-color);
            margin:0;
            text-align:center;
            max-width:1000px;
          }

          footer{
            width:100%;
            text-align:center;
            padding:20px 10px;
            box-sizing:border-box;
            border-top:1px solid rgba(255,255,255,0.06);
          }
          footer .line{
            display:block;
            color:var(--text-color);
            font-size:24px;
            margin:6px 0;
            line-height:1.3;
          }
          footer a{
            color:var(--text-color);
            text-decoration:underline;
          }

          @media (max-width:480px){
            header h1{ font-size:30px; }
            main p{ font-size:20px; }
            footer .line{ font-size:18px; }
          }
        </style>
      </head>
      <body>
        <div class="container">
          <header>
            <h1>Felicitaciones!</h1>
          </header>

          <main>
            <p>Si ves o lees este mensaje, significa que tu servidor web esta funcionando.</p>
          </main>

          <footer>
            <span class="line">Archivo HTML de prueba creado por VampireNightXX.</span>
            <span class="line">Apoya a VampireNightXX ingresando a su sitio en GitHub y dandole estrella a sus repositorios!</span>
            <span class="line"><a href="https://github.com/vampirenightxx" target="_blank" rel="noopener noreferrer">https://github.com/vampirenightxx</a></span>
            <span class="line">VampireNightXX - Vaska HTML Simple Test File. Creado por VampireNightXX.</span>
            <span class="line">Acentos omitidos intencionalmente.</span>
          </footer>
        </div>
      </body>
      </html>
      EOF
      SCRIPT
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_connect_user 
      private_key = tls_private_key.rsa_key.private_key_pem
      host        = self.public_ip
    }
  }
}

###############################################################################
# BLOQUE 5 - ALMACENAMIENTO DE OBJETOS CONTROLADO (AMAZON S3)
###############################################################################

resource "aws_s3_bucket" "storage" {
  bucket        = var.s3_bucket_name    
  force_destroy = var.s3_force_destroy 

  tags = {
    Name = var.s3_bucket_name
  }
}

resource "aws_s3_bucket_versioning" "storage_versioning" {
  bucket = aws_s3_bucket.storage.id
  versioning_configuration {
    status = var.s3_versioning_status 
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "storage_crypto" {
  bucket = aws_s3_bucket.storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.s3_encryption_algorithm 
    }
  }
}

resource "aws_s3_bucket_public_access_block" "storage_public_block" {
  bucket = aws_s3_bucket.storage.id

  block_public_acls       = var.s3_bucket_is_public ? false : true
  block_public_policy     = var.s3_bucket_is_public ? false : true
  ignore_public_acls      = var.s3_bucket_is_public ? false : true
  restrict_public_buckets = var.s3_bucket_is_public ? false : true
}

resource "aws_s3_bucket_policy" "public_read_policy" {
  count  = var.s3_bucket_is_public ? 1 : 0
  bucket = aws_s3_bucket.storage.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*" 
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.storage.arn}/*" 
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.storage_public_block]
}

###############################################################################
# BLOQUE 6 - LOGS DE CONTROL Y SALIDAS (OUTPUTS)
###############################################################################

# =============================================================================
# 1. GEOGRAFÍA Y UBICACIÓN
# =============================================================================

output "aws_region" {
  description = "Region geografica de AWS donde se ha desplegado toda la infraestructura"
  value       = var.aws_region
}

# =============================================================================
# 2. SEGURIDAD Y ACCESO SSH (LLAVES CRIPTOGRÁFICAS)
# =============================================================================

output "ssh_key_name" {
  description = "Nombre identificador de la llave SSH registrada en la consola de AWS"
  value       = aws_key_pair.deployer_key.key_name
}

output "ssh_key_filename" {
  description = "Nombre y ruta del archivo fisico .pem guardado en el disco de Ubuntu"
  value       = var.ssh_key_filename
}

output "tls_key_bits" {
  description = "Robustez y tamano criptografico en bits de la llave privada RSA generada"
  value       = var.tls_key_bits
}

output "ssh_connect_user" {
  description = "Nombre del usuario predeterminado de la AMI para establecer la conexion SSH"
  value       = var.ssh_connect_user
}

# =============================================================================
# 3. ARQUITECTURA DE RED (NETWORKING)
# =============================================================================

output "vpc_id" {
  description = "Identificador unico de la Virtual Private Cloud (VPC)"
  value       = aws_vpc.main.id
}

output "vpc_name" {
  description = "Nombre comercial asignado como etiqueta (Tag: Name) a la VPC"
  value       = aws_vpc.main.tags["Name"]
}

output "vpc_cidr_block" {
  description = "Bloque de direccionamiento IP primario (Rango CIDR absoluto) de la VPC"
  value       = aws_vpc.main.cidr_block
}

output "subnet_public_a_id" {
  description = "Identificador unico de la Subred Publica de la zona A"
  value       = aws_subnet.public_a.id
}

output "subnet_public_a_name" {
  description = "Nombre asignado como etiqueta (Tag: Name) a la Subred Publica A"
  value       = aws_subnet.public_a.tags["Name"]
}

output "subnet_public_a_cidr" {
  description = "Rango de direccionamiento IP interno (CIDR) asignado a la Subred Publica A"
  value       = aws_subnet.public_a.cidr_block
}

output "subnet_public_a_az" {
  description = "Zona de disponibilidad fisica en AWS asignada a la Subred Publica A"
  value       = aws_subnet.public_a.availability_zone
}

output "subnet_public_b_id" {
  description = "Identificador unico de la Subred Publica de la zona B"
  value       = aws_subnet.public_b.id
}

output "subnet_public_b_name" {
  description = "Nombre asignado como etiqueta (Tag: Name) a la Subred Publica B"
  value       = aws_subnet.public_b.tags["Name"]
}

output "subnet_public_b_cidr" {
  description = "Rango de direccionamiento IP interno (CIDR) asignado a la Subred Publica B"
  value       = aws_subnet.public_b.cidr_block
}

output "subnet_public_b_az" {
  description = "Zona de disponibilidad fisica en AWS asignada a la Subred Publica B"
  value       = aws_subnet.public_b.availability_zone
}

output "internet_gateway_name" {
  description = "Nombre logico asignado a la compuerta de internet (Internet Gateway)"
  value       = var.internet_gateway_name
}

output "route_table_name" {
  description = "Nombre logico asignado a la Tabla de Enrutamiento Publica"
  value       = var.route_table_name
}

# =============================================================================
# 4. SEGURIDAD PERIMETRAL (SECURITY GROUPS & PUERTOS)
# =============================================================================

output "security_group_id" {
  description = "Identificador unico del Security Group (Cortafuegos)"
  value       = aws_security_group.web.id
}

output "security_group_name" {
  description = "Nombre del Security Group aplicado al trafico perimetral"
  value       = aws_security_group.web.name
}

output "security_group_ssh_port" {
  description = "Puerto de red de entrada autorizado para conexiones administrativas SSH"
  value       = var.ssh_port
}

output "security_group_http_port" {
  description = "Puerto de red de entrada autorizado para navegacion web publica HTTP"
  value       = var.http_port
}

output "security_group_allowed_cidrs" {
  description = "Bloques CIDR remotos habilitados para interactuar con los puertos abiertos"
  value       = var.allowed_cidr_blocks
}

# =============================================================================
# 5. RECURSOS DE CÓMPUTO (EC2 & SISTEMA OPERATIVO)
# =============================================================================

output "instance_id" {
  description = "Identificador unico de la instancia de computo EC2"
  value       = aws_instance.app.id
}

output "instance_name" {
  description = "Nombre asignado como etiqueta (Tag: Name) al servidor web"
  value       = aws_instance.app.tags["Name"]
}

output "instance_type" {
  description = "Tipo de instancia o dimensionamiento de capacidad de hardware (CPU/RAM)"
  value       = aws_instance.app.instance_type
}

output "instance_ami_id" {
  description = "ID exacto de la imagen de AWS (AMI) de Ubuntu resuelta dinamicamente"
  value       = aws_instance.app.ami
}

output "instance_public_ip" {
  description = "Direccion IP Publica asignada al servidor (Util para conexiones SSH externas)"
  value       = aws_instance.app.public_ip
}

output "website_url" {
  description = "Enlace publico directo para abrir y auditar el sitio web Apache en ejecucion"
  value       = "http://${aws_instance.app.public_ip}"
}

# =============================================================================
# 6. ALMACENAMIENTO DE OBJETOS (AMAZON S3)
# =============================================================================

output "s3_bucket_name" {
  description = "Nombre oficial, definitivo y unico a nivel mundial del Bucket S3"
  value       = aws_s3_bucket.storage.id
}

output "s3_bucket_status" {
  description = "Estado actual de visibilidad y politicas perimetrales de acceso al Bucket S3"
  value       = var.s3_bucket_is_public ? "PUBLICO (Acceso universal a objetos habilitado)" : "PRIVADO (Protegido y seguro)"
}

output "s3_force_destroy" {
  description = "Resguardo de eliminacion: false exige vaciado manual previo; true permite purga total automatica"
  value       = var.s3_force_destroy
}

output "s3_versioning_status" {
  description = "Estado actual del control de versiones en caliente de los objetos"
  value       = var.s3_versioning_status
}

output "s3_encryption_algorithm" {
  description = "Algoritmo de cifrado por defecto aplicado del lado de AWS (Server-Side Encryption)"
  value       = var.s3_encryption_algorithm
}

output "s3_bucket_download_url_example" {
  description = "Estructura de URL prototipo para consumir archivos publicos de este repositorio de datos"
  value       = "https://${aws_s3_bucket.storage.id}.s3.amazonaws.com/nombre_de_tu_archivo.ext"
}
