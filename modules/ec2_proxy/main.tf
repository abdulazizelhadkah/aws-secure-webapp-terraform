resource "aws_instance" "proxy" {
  count                       = var.instance_count
  ami                         = "ami-0bdd88bd06d16ba03"
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = true
  key_name                    = var.key_name

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.ssh_private_key_path)
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_proxy.sh"
    destination = "/home/ec2-user/install_proxy.sh"
  }

 provisioner "file" {
    # Use 'content' instead of 'source'
    content = templatefile("${path.module}/scripts/nginx.conf.tftpl", {
      # Pass the variable into the template
      internal_alb_dns_name = var.internal_alb_dns_name
    })
    destination = "/tmp/nginx.conf" # Destination remains /tmp
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/install_proxy.sh",
      "sudo /home/ec2-user/install_proxy.sh", # This installs Nginx

      # 1. Move config and set permissions
      "sudo mv /tmp/nginx.conf /etc/nginx/nginx.conf",
      "sudo chown root:root /etc/nginx/nginx.conf",
      "sudo chmod 644 /etc/nginx/nginx.conf",

      "sudo restorecon /etc/nginx/nginx.conf",
      # 2. 🛑 Test the config file syntax
      # This command will fail if the config is bad, and
      # print the exact error message to your 'terraform apply' output.
      "sudo nginx -t",

      "sudo setsebool -P httpd_can_network_connect 1",

      # 3. If test passes, enable and start the service.
      # 'enable --now' handles both in one command.
      "sudo systemctl enable --now nginx || echo 'NGINX FAILED TO START, continuing provisioner...'"
    ]
  }

  tags = merge(
    var.tags,
    { Name = "${var.gow}-proxy-${count.index + 1}" }
  )
}
