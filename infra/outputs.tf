output "instance_public_ip" {
  value = module.ec2.public_ip
}

output "sonar_public_ip" {
  value = module.sonarqube.public_ip
}