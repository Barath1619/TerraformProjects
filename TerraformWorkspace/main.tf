provider "aws" {
    region = "us-east-1"
}

variable "ami" {
  default = "ami-020cba7c55df1f615"
}

variable "instance_type" { 
type = map(string)
default = {
  "prod" = "t2.micro"
  "dev" = "t2.micro",
  "test" = "t2.micro"
}
}

module "EC2" {
  source = "./modules/EC2Instance"
  ami = var.ami
  instance_type = lookup(var.instance_type, terraform.workspace, "t2.micro")
}