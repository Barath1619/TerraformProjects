output "EC2_public_IP" {
    value       = {
        public_ip = aws_instance.demo.public_ip
        private_ip = aws_instance.demo.private_ip

    }
  
}