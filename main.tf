
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_net
  tags = {
    Name = "dev"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "dev-igw"
  }
}

resource "aws_subnet" "subnet" {
  count = length(var.listSubnet)
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.listSubnet[count.index]
  /*dynamic "subnet" {
    for_each = var.subnet
    content {
      name = subnet
    }
  }*/
  tags = {
    Name = "Subnet${count.index}"
  }
}

resource "aws_route_table" "routeTb" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "routeTable"
  }
}
#output "printSubnet" {
#  value = aws_subnet.subnet[*]
#}

resource "aws_route_table_association" "TableAssociation" {
  count = length(var.listSubnet)
  subnet_id = element(aws_subnet.subnet.*.id, count.index )
  route_table_id = aws_route_table.routeTb.id
}
/*
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "myKey"       # Create a "myKey" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { # Create a "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.pk.private_key_pem}' > C:/Users/florient.dogbe_group/Documents/MyRepo/17032022/myKey.pem"
  }
}*/


resource "aws_security_group" "securityGroup" {
  name = "k8s_securityGroup"
  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    description = "Allow ssh connection from external"
    cidr_blocks = [var.allPublic]
  }
  ingress {
    from_port = 8080
    protocol  = "tcp"
    to_port   = 8080
    description = "Allow ssh connection from external"
    cidr_blocks = [var.allPublic]
  }
  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    description = "Allow only intranet traffic"
    cidr_blocks = [var.Subent-net]
  }
  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "k8sSecurityGroup"
  }
}


## Create a AWS key pair using the ssh key generated previously
## Stores the public key in aws and private key in the local system
resource "aws_key_pair" "generated_key" {
  key_name   = var.generated_key_name
  public_key = file("~/.ssh/id_rsa.pub")
}
/*
resource "aws_security_group" "sg" {

}*/