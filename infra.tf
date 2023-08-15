terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "terraform-file-8th-aug"
    key    = "terraform-Infra-file.tf"
    region = "us-east-2"
  }
}


#  Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

# resource "aws_instance" "web" {
#   ami           = "ami-069d73f3235b535bd"
#   instance_type = "t2.micro"
#   key_name      = "Linux-Demo-17th-June"
#   tags = {
#     Name = "HelloWorld"
#   }
# }


# resource "aws_eip" "lb" {
#   instance = aws_instance.web.id
#}
# creating the vpc resources
resource "aws_vpc" "florida-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Florida-vpc"
  }
}
# creating the subnets resources
resource "aws_subnet" "florida-subnet-2a" {
  vpc_id                  = aws_vpc.florida-vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Florida-subnet-2a"
  }
}

resource "aws_subnet" "florida-subnet-2b" {
  vpc_id                  = aws_vpc.florida-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Florida-subnet-2b"
  }
}

resource "aws_subnet" "florida-subnet-2c" {
  vpc_id                  = aws_vpc.florida-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-2c"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Florida-subnet-2c"
  }
}

# creating the ec2 instances
resource "aws_instance" "florida-instace" {
  ami                    = "ami-07f7a72f74cc6ead3"
  instance_type          = var.florida_instance_type
  key_name               = aws_key_pair.florida-key-pair.id
  subnet_id              = aws_subnet.florida-subnet-2a.id
  vpc_security_group_ids = [aws_security_group.florida_SG_allow_ssh_http.id]

  tags = {
    Name = "Florida-Instance"
  }
}

resource "aws_instance" "florida-instace-2" {
  ami                    = "ami-07f7a72f74cc6ead3"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.florida-key-pair.id
  subnet_id              = aws_subnet.florida-subnet-2b.id
  vpc_security_group_ids = [aws_security_group.florida_SG_allow_ssh_http.id]

  tags = {
    Name = "Florida-Instance-2"
  }
}


# Creating key pair
resource "aws_key_pair" "florida-key-pair" {
  key_name   = "florida-10th-july"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNgTlMmNbfnQczHSOgBPcDHmmt6vJLKZ+a5ODkz72BVlQkY5ol2WomNgx2mweBpnB9aWIWKeoeSUX3ZpjTSP3Q1YDscry65CJZ7tWuxeoOAJ6pcT5YTWpYMaTSligNOXUE3MKX33XqtOxHHOh0TmfTBJy/FkBCzjSPE+Vv2T87iNtoAm9Q84f13g4Tv5EKFQUYtemmoWBJN3U+IO+fSZ/LnXwWMPvj+WPKtd0aDhw5Qa+toHWBdvg+RJmIoH2Pz3IR0sag4HpopffT4JsvkeNfSnv8Ye/Jne7I5i9FzkhafZduzZy9KacwuwkrY1lmig9f6wXmbnJHwsNaE2+v8qrB4rt6AxZfzNg23puH9qarjNizp1RHZe839A3Z6gQ/gm6QvpL4+PsjxYw6kygTUyz4d47iDUabWoqlM8ABqoUpc2s9RzYvLPUdX5TtTg0TVm4zT8Ifj5NiI6/t+5Aid6ZtB5AtQoza0nHCcbVtV+uzrcCZ0R/Plehcjz7x9d4ecoE= newtongaussian@Newtons-MBP.lan"
}

# creating the security group

resource "aws_security_group" "florida_SG_allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = aws_vpc.florida-vpc.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
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
    Name = "allow_ssh_http"
  }
}

# creating Internet gateway
resource "aws_internet_gateway" "florida_IG" {
  vpc_id = aws_vpc.florida-vpc.id

  tags = {
    Name = "Florida-IG"
  }
}

# creating the route table
resource "aws_route_table" "florida-RT" {
  vpc_id = aws_vpc.florida-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.florida_IG.id
  }

  tags = {
    Name = "Florida-RT"
  }
}

# creating the route table association attach to subnet
resource "aws_route_table_association" "florida-RT-association-2a" {
  subnet_id      = aws_subnet.florida-subnet-2a.id
  route_table_id = aws_route_table.florida-RT.id
}

resource "aws_route_table_association" "florida-RT-association-2b" {
  subnet_id      = aws_subnet.florida-subnet-2b.id
  route_table_id = aws_route_table.florida-RT.id
}

# Creating Target group 
resource "aws_lb_target_group" "florida-TG" {
  name     = "card-website-app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.florida-vpc.id
}

resource "aws_lb_target_group_attachment" "florida-TG-attachment-1" {
  target_group_arn = aws_lb_target_group.florida-TG.arn
  target_id        = aws_instance.florida-instace.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "florida-TG-attachment-2" {
  target_group_arn = aws_lb_target_group.florida-TG.arn
  target_id        = aws_instance.florida-instace-2.id
  port             = 80
}

resource "aws_lb_listener" "florida-listener" {
  load_balancer_arn = aws_lb.florida-LB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.florida-TG.arn
  }
}
# Creating Load Balancer
resource "aws_lb" "florida-LB" {
  name               = "card-website-app-LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.florida_SG_allow_ssh_http.id]
  subnets            = [aws_subnet.florida-subnet-2a.id, aws_subnet.florida-subnet-2b.id]

  tags = {
    Environment = "prod"
  }
}

# Creating Launch Template

resource "aws_launch_template" "florida-LT" {
  name = "florida-LT"

  image_id      = "ami-024e6efaf93d85776"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.florida-key-pair.id

  monitoring {
    enabled = true
  }


  placement {
    availability_zone = "us-west-2a"
  }

  vpc_security_group_ids = [aws_security_group.florida_SG_allow_ssh_http.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "florida-instance-ASG"
    }
  }
  user_data = filebase64("userdata.sh")
}

#Creating ASG
resource "aws_autoscaling_group" "florida-ASG" {
  vpc_zone_identifier = [aws_subnet.florida-subnet-2a.id, aws_subnet.florida-subnet-2b.id]

  desired_capacity = 2
  max_size         = 5
  min_size         = 2


  launch_template {
    id      = aws_launch_template.florida-LT.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.florida-TG-1.arn]
}

# ALB TG with ASG

resource "aws_lb_target_group" "florida-TG-1" {
  name     = "florida-TG-1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.florida-vpc.id
}

# LB Listener with ASG

resource "aws_lb_listener" "florida-listener-1" {
  load_balancer_arn = aws_lb.florida-LB-1.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.florida-TG-1.arn
  }
}

#load balancer with ASG

resource "aws_lb" "florida-LB-1" {
  name               = "florida-LB-1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.florida_SG_allow_ssh_http.id]
  subnets            = [aws_subnet.florida-subnet-2a.id, aws_subnet.florida-subnet-2b.id]


  tags = {
    Environment = "production"
  }
}

