 provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "my_key" {
  key_name = "mykey"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_vpc" "demovpc01" {
  cidr_block = var.vpccidr
  tags = {
    Name="demovpc01"
  }
}
resource "aws_subnet" "sub1" {
  vpc_id = aws_vpc.demovpc01.id
  cidr_block = var.subnetcidr1
  map_public_ip_on_launch = true
  availability_zone = var.az1

  tags = {
    Name = "sub1"
  }
}

resource "aws_subnet" "sub2" {

  vpc_id = aws_vpc.demovpc01.id
  cidr_block = var.subnetcidr2
  map_public_ip_on_launch = true
  availability_zone = var.az2
  tags = {
    Name="sub2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.demovpc01.id
}

resource "aws_route_table" "rtpublic" {
  vpc_id = aws_vpc.demovpc01.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name="rtpublic"
  }
}

# resource "aws_route_table" "rtprivate" {
#   vpc_id = aws_vpc.demovpc01.id
#   route {
#     cidr_block = "0.0.0.0/0"
#   }
#   tags = {
#     Name="rtprivate"
#   }
# }

resource "aws_route_table_association" "rta1" {
  route_table_id = aws_route_table.rtpublic.id
  subnet_id = aws_subnet.sub1.id
}

# resource "aws_route_table_association" "rta2" {
#   route_table_id = aws_route_table.rtprivate.id
#   subnet_id = aws_subnet.sub2.id
# }

resource "aws_security_group" "web-sg" {
    name = "web"
    vpc_id = aws_vpc.demovpc01.id
    ingress {
        description = " Allow HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Allow SSH"
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
}

resource "aws_instance" "ec2" {
    ami = var.ami_id
    key_name = aws_key_pair.my_key.key_name
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_security_group.web-sg.id]
    subnet_id = aws_subnet.sub1.id
    tags = {
        Name = var.instanceName
    }
    connection {
      type = "ssh"
      host = self.public_ip
      user = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
    }

    provisioner "file" {
      source = "app.py"
      destination = "/home/ubuntu/app.py"
    }

    provisioner "remote-exec" {

        inline = [ 
            "echo 'Hello from the remote instance'",
            "sudo apt update -y",
            "sudo apt-get install -y python3-pip",  # pip and python package installation
            "cd /home/ubuntu",
            "sudo apt install -y python3-venv",
            "python3 -m venv flaskenv",
            "source flaskenv/bin/activate && pip install flask",
            "nohup flaskenv/bin/python3 app.py &",
         ]
      
    }

}