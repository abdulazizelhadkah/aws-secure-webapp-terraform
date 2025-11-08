resource "aws_instance" "backend" {
  count                       = var.instance_count
  ami                         = "ami-0bdd88bd06d16ba03"
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_name
  associate_public_ip_address = false

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.ssh_private_key_path)
    host        = self.private_ip
    bastion_host = var.proxy_public_ip
  }

  provisioner "file" {
    source      = var.local_backend_path
    destination = "/tmp/webapp"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/deploy_backend.sh"
    destination = "/home/ec2-user/deploy_backend.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/deploy_backend.sh",
      "sudo /home/ec2-user/deploy_backend.sh"
    ]
  }

  tags = merge(
    var.tags,
    { Name = "${var.gow}-backend-${count.index + 1}" }
  )
}