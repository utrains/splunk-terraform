# print the url of the jenkins server
output "ssh_splunk_forwader_command" {
  value     = join ("", ["ssh -i splunkkey.pem ec2-user@", aws_instance.splunk-forwarder.public_dns])
}

output "ssh_splunk_server_command" {
  value     = join ("", ["ssh -i splunkkey.pem ec2-user@", aws_instance.splunk-server.public_dns])
}