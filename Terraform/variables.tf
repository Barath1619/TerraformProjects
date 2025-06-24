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