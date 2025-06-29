provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "demo" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "Demo VPC"
    }
}

resource "aws_subnet" "sb1" {
    vpc_id            = aws_vpc.demo.id
    cidr_block        = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
      Name = "sb1"
    }
}

resource "aws_subnet" "sb2" {
    vpc_id            = aws_vpc.demo.id
    cidr_block        = "10.0.1.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true
    tags = {
      Name = "sb2"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.demo.id
}

resource "aws_route_table" "name" {
    vpc_id = aws_vpc.demo.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
  
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sb1.id
  route_table_id = aws_route_table.name.id
}


resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sb2.id
  route_table_id = aws_route_table.name.id
}

resource "aws_security_group" "mysg" {
    name_prefix = "web-sg-"
    vpc_id = aws_vpc.demo.id
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
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
      Name = "web-sg"
    }
}

resource "aws_s3_bucket" "S3" {
  bucket = "news3bucket0001mydemobucket"
}

# resource "aws_s3_bucket_acl" "example" {
#     bucket = aws_s3_bucket.S3
# }

resource "aws_instance" "server1" {
  ami = "ami-020cba7c55df1f615"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id = aws_subnet.sb1.id
  user_data = base64encode(file("userdata1.sh"))
}

resource "aws_instance" "server2" {
    ami = "ami-020cba7c55df1f615"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.mysg.id]
    subnet_id = aws_subnet.sb2.id
    user_data = base64encode(file("userdata2.sh"))
}

#Application Load Balancer

resource "aws_lb" "mylb" {
  
  name = "mylb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.mysg.id]
  subnets = [aws_subnet.sb1.id, aws_subnet.sb2.id]

}

resource "aws_lb_target_group" "tg1" {
    name     = "tg1"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.demo.id
    health_check {
      path = "/"
      port = "traffic-port"
    }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg1.arn
  target_id        = aws_instance.server1.id
  port = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
    target_group_arn = aws_lb_target_group.tg1.arn
    target_id        = aws_instance.server2.id
    port = 80
}

resource "aws_lb_listener" "list" {
  load_balancer_arn = aws_lb.mylb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.tg1.arn
    type             = "forward"
  }
}

output "lb_details" {
  value = aws_lb.mylb.dns_name
}