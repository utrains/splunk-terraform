# Create a VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "splunk VPC"
  }
}


# Create Web Public Subnet
resource "aws_subnet" "web-subnet" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  #availability_zone = "us-east-2a"

  tags = {
    Name = "splunk-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "splunk IGW"
  }
}

# Create Web layber route table
resource "aws_route_table" "web-rt" {
  vpc_id = aws_vpc.my-vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "WebRT"
  }
}

# Create Web Subnet association with Web route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.web-subnet.id
  route_table_id = aws_route_table.web-rt.id
 }


  # Create Web Security Group
resource "aws_security_group" "web-sg" {
    name        = "splunk security group"
    description = "Allow ssh inbound traffic"
    vpc_id      = aws_vpc.my-vpc.id
  
    ingress {
      description = "ssh from VPC"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      description = "ssh from VPC splunk server"
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  ingress {
      description = "ssh from VPC splunk forwader"
      from_port   = 9997
      to_port     = 9997
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }    
    
  ingress {
    description = "http port"
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
      Name = "splunk-SG"
    }
}
  

#data for amazon linux

data "aws_ami" "amazon_linux_2" {
    most_recent = true
  
    filter {
      name = "name"
      #values = ["amzn2-ami-hvm-*-x86_64-ebs"]
      values = ["amzn-ami-hvm-*x86_64-gp2"]
    }
    owners = ["amazon"]
}

#create ec2 instances

//---
resource "aws_instance" "splunk-server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.aws_instance_type
  subnet_id              = aws_subnet.web-subnet.id
  vpc_security_group_ids = ["${aws_security_group.web-sg.id}"]
  key_name               = aws_key_pair.ec2-key.key_name
  user_data            = file("splunk_script.sh")
  # Set the instance's root volume to 30 GB
  root_block_device {
    volume_size = 30
  }

 
  tags = {
    Name = "splunk-server"
    owner   = "splunk"
    Environment = "dev"
  }
}

resource "aws_instance" "splunk-forwarder" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.aws_instance_type
  subnet_id              = aws_subnet.web-subnet.id
  vpc_security_group_ids = ["${aws_security_group.web-sg.id}"]
  key_name               = aws_key_pair.ec2-key.key_name
  user_data            = file("splunk_forwarder_script.sh")
  # Set the instance's root volume to 30 GB
  root_block_device {
    volume_size = 30
  }

    tags = {
      Name = "splunk-forwarder"
      owner   = "splunk"
      Environment = "dev"
  }
}

/*---

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  #version = ">= 3.0"

  for_each = toset(["splunk-server", "splunk-forwarder"])

  name = "instance-${each.key}"

  ami                    = "${data.aws_ami.amazon_linux_2.id}"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ec2-key.key_name
  monitoring             = true
  vpc_security_group_ids = ["${aws_security_group.web-sg.id}"]
  subnet_id              = aws_subnet.web-subnet.id
  #user_data            = file("install.sh")
  

  tags = {
    owner   = "splunk"
    Environment = "dev"
  }
 
}
/*resource "aws_volume_attachment" "this" {
  for_each = module.ec2_instance
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.this[each.key].id
  instance_id = each.value.id
  force_detach = true
}

resource "aws_ebs_volume" "this" {
for_each = module.ec2_instance
  availability_zone = "us-east-2a"
  size              = 30
  tags = {
    Name = "Myvol-${each.key}"
  }
}*/