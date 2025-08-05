output "master" {
    value = aws_instance.master.public_ip
}

output "slave1" {
    value = aws_instance.slave1.public_ip
}

output "slave2" {
    value = aws_instance.slave2.public_ip
}