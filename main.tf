

# Generate a new SSH key pair
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096 
}

# Store the public key in AWS
resource "aws_key_pair" "generated_key" {
  key_name   = "my-generated-key"
  public_key = tls_private_key.my_key.public_key_openssh
}

# Save the private key locally
resource "local_file" "private_key" {
  filename        = "C:/Users/Owner/keys/my-generated-key.pem"
  content         = tls_private_key.my_key.private_key_pem
  
  }

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}

# Create a Subnet in the VPC

resource "aws_subnet" "subnet1" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true

    tags = {
        Name = "subnet1"
    }
  
}

# Create an Internet Gateway

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "igw"
    }
  
}

# Create route table for public access

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block ="0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
   tags ={
         Name = "public_rt"
   } 
}

# Associate the route table with the subnet

resource "aws_route_table_association" "rta" {
    subnet_id = aws_subnet.subnet1.id
    route_table_id = aws_route_table.public_rt.id
  
}

# Create a Security Group
resource "aws_security_group" "sg1" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg1"
  }
}

# Create EC2 Instance
resource "aws_instance" "Client-VM" {
  ami                    = "ami-04681163a08179f28"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.sg1.id]  # ✅ Correct reference
  subnet_id = aws_subnet.subnet1.id

  tags = {
    Name = "Client-VM"
  }
}

# Outputs
output "key_pair_name" {
  value = aws_key_pair.generated_key.key_name
}

output "public_ip" {
  value = aws_instance.Client-VM.public_ip
}
