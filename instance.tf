/*data "aws_key_pair" "mykey" {
  key_name = "myKey"
}*/



resource "aws_instance" "control" {
  instance_type = "t3.medium"
  ami = var.instanceAmi
  vpc_security_group_ids = [aws_security_group.securityGroup.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.generated_key.key_name
  tags = {
    Name = "Controller"
  }
  user_data = file("./WorkerHostname.sh")
}


resource "aws_instance" "deployEc2" {
  count = 3
  instance_type = "t3.medium"
  ami = var.instanceAmi
  vpc_security_group_ids = [aws_security_group.securityGroup.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.generated_key.key_name

  tags = {
    Name = "Worker${count.index}"
  }
  user_data = templatefile("./WorkerHostname.sh", {Number = count.index})
}

output "controllerPublicIP" {
  value = "ssh ec2-user@${aws_instance.control.public_ip}"
}

output "controllerPrivateIP" {
  value = aws_instance.control.private_ip
}

output "WorkerNodeIp" {
  value = aws_instance.deployEc2[*].public_ip
}

output "WorkerNodePrivaIp" {
  value = aws_instance.deployEc2[*].private_ip
}
#output "WorkerNodeIP" {
#  value = "${aws_instance.deployEc2[*].private_ip} -- ${aws_instance.deployEc2[*].public_ip}"
#}