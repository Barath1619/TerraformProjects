variable "vpccidr" {
  description = "vpc cidr range"
  type        = string
  default = "10.0.0.0/16"
}
variable "subnetcidr1" {
    description = "subnet cidr range"
    type        = string
    default     = "10.0.1.0/24"
}
variable "subnetcidr2" {
    description = "subnet cidr range"
    type        = string
    default     = "10.0.2.0/24"
}
variable "az1" {
    description = "availability zone"
    type        = string
    default = "us-east-1a"
}

variable "az2" {
    description = "availability zone"
    type        = string
    default = "us-east-1b"
}

variable "ami_id" {
  description = "value of the AMI"
  default = "ami-020cba7c55df1f615"
  type = string
}
variable "instance_type" {
  description = "value of instance type"
  type = string
  default = "t2.micro"
}
variable "instanceName" {
  description = "name of the EC2 Instance"
  type = string
  default = "DemoEC2"
}