#create a vpc

resource "aws_vpc" "hp_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "hp_vpc"
  }
}


#Create a Public Subnet

resource "aws_subnet" "Public-hp-subnet" {
  vpc_id = aws_vpc.hp_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "hp-vpc-public-subnet"
  }
}


#Create a Private Subnet

resource "aws_subnet" "Private-hp-subnet" {
  vpc_id = aws_vpc.hp_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "hp-vpc-private-subnet"
  }
}


#Create Internet Gateway

resource "aws_internet_gateway" "hp-internet-gateway" {
  vpc_id = aws_vpc.hp_vpc.id
  tags = {
    Name = "hp-internet-gateway"
  }
}

#Create Public Route Table

resource "aws_route_table" "hp-Public-RouteTable" {
  vpc_id = aws_vpc.hp_vpc.id
    tags = {
      Name = "hp-Public-RouteTable"
  }
}

#Create Private Route Table
resource "aws_route_table" "hp-Private-RouteTable" {
  vpc_id = aws_vpc.hp_vpc.id
    tags = {
      Name = "hp-Private-RouteTable"
  }
}

#Associate Public subnet with Public Route Table

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.Public-hp-subnet.id
  route_table_id = aws_route_table.hp-Public-RouteTable.id
}

# Create a NAT gateway for the public subnet to access the internet

# resource "aws_nat_gateway" "hp-Nat-Gateway" {
#   allocation_id = "eipalloc-07ff157fe24bfb93e"
#   subnet_id     = aws_subnet.Public-hp-subnet.id

#   tags = {
#     Name = "hp-Nat-Gateway"
#   }
# }


# Creating NAT Gateway without elastic ip
resource "aws_nat_gateway" "hp-Nat-Gateway" {
subnet_id = aws_subnet.Public-hp-subnet.id
tags = {
Name = "hp-Nat-Gateway"
}
}



#Associate Private Subnet with NAT Gateway

resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.Private-hp-subnet.id
  route_table_id = aws_route_table.hp-Private-RouteTable.id
}

#Associate Natgateway with route table

resource "aws_route" "private_nat_gateway" {
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.hp-Nat-Gateway.id
  route_table_id = aws_route_table.hp-Private-RouteTable.id
}     

#Associate internet-gateway with route table

resource "aws_route" "public_internet_gateway" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.hp-internet-gateway.id
  route_table_id = aws_route_table.hp-Public-RouteTable.id
}     

#Creating of EC2 Instance
resource "aws_instance" "hp-EC2" {
  ami = var.ami-id
  instance_type = var.instance-type
  subnet_id = aws_subnet.Public-hp-subnet.id
  availability_zone = var.availability-zone

  tags = {
    Name = "hp-EC2-Instance" 
}
}  


#Deattach the volume 
resource "aws_volume_attachment" "Dettach_volume" {
  device_name = "/dev/xvda"
  volume_id = var.volume-id
  instance_id = var.instance-id
}

#Attach the volume 
resource "aws_volume_attachment" "Attach_volume" {
  device_name = "/dev/xvda"
  volume_id = var.volume-id
  instance_id = var.instance-id
}


#Creation of KMS Key
resource "aws_kms_key" "hp-key"{
  description = "hp-key"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
         Sid = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "kms:*"
        ]
        Resource = "*"
      }
    ]
  })
  tags = {
    Environment = "hp"
  }
}


#Encrypting the Volume with KMS key

resource "aws_ebs_volume" "hp-Encrypt" {
  availability_zone = var.availability-zone
  type = "gp3"
  size = "8"
  encrypted = "true"
  kms_key_id = "arn:aws:kms:us-east-1:852598404117:key/28b7e03b-653a-4eb3-b3d9-02dafd93e81f"
}


#Security Group for RDS

resource "aws_security_group" "Security_Group_DB" {
  name_prefix = "hp_Security_Group_DB"
  description = "Security_Group_DB"
  vpc_id = aws_vpc.hp_vpc.id

 ingress {                        #inbound
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
egress {                            #outbound
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}













