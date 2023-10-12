# print the url of the splunk server and the splunk forwader
output "ssh_splunk_forwader_command" {
  value     = join ("", ["ssh -i splunkkey.pem ec2-user@", aws_instance.splunk-forwarder.public_dns])
}

output "Connexion_link_for_the_splunk_server" {
  value     = join ("", ["http://", aws_instance.splunk-server.public_ip, ":", "8000"])
}
#output "Connexion_link_for_the_splunk_forwarder" {
#  value     = join ("", ["http://", aws_instance.splunk-forwarder.public_ip, ":", "9997"])
#}

output "ssh_splunk_server_command" {
  value     = join ("", ["ssh -i splunkkey.pem ec2-user@", aws_instance.splunk-server.public_dns])
}
