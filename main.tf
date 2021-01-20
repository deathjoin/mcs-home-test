resource "openstack_compute_keypair_v2" "ssh" {
  name = "terraform_ssh_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGFXcVzlEMxzxYQd56iirTTM56qYb71fSKzuf8y28UHy2N17SWiQ/kXedmcKLnz8zb1Q/dJeUvpjYrKKC6XZElsNl6jd8dXqxJ6CvUQYcouGZOEqQOUvkr/3geFajh9YC50Pz1wAj8DbZ/anX/yEIKfK6YDuEx3XiRnNs109HtGK5UR4/QeYy+Wy+YvYGQ4PEOUQwm2h00WvZiTpHAumQ0aqcpc+wB4Ltc/SJR22sGqIHQ1WWhAj3RW3QpF644fDDpImtBjEKb5ygbBfqePXKI1yNHEvAoKdzxXoKkFVgIS09EHpRquHLdsq3O7/UghfxDyV1ebMyf10dpThTiWSWb Generated-by-Nova"
}

resource "openstack_compute_secgroup_v2" "rules" {
  name = "terraform__security_group"
  description = "security group for terraform instance"
  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = -1
    to_port = -1
    ip_protocol = "icmp"
    cidr = "0.0.0.0/0"
  }
}

resource "openstack_blockstorage_volume_v2" "volume" {
  name = "storage"
  volume_type = "dp1"
  
  size = "50"

  # CentOS-7.7-202003
  image_id = "4525415d-df00-4f32-a434-b8469953fe3e"
}

resource "openstack_compute_instance_v2" "instance" {
  # Название создаваемой ВМ
  name = "terraform-test"

  # Имя и uuid образа с ОС
  image_name = "CentOS-7.7-202003"
  image_id = "4525415d-df00-4f32-a434-b8469953fe3e"
  flavor_name = "Standard-4-16-50"

  key_pair = openstack_compute_keypair_v2.ssh.name

  config_drive = true

  security_groups = [
   openstack_compute_secgroup_v2.rules.name
  ]

  network {
    name = "ext-net"
  }

  block_device {
    uuid = openstack_blockstorage_volume_v2.volume.id
    boot_index = 0
    source_type = "volume"
    destination_type = "volume"
    delete_on_termination = true
  }

  provisioner "remote-exec" {
    connection {
      host = openstack_compute_instance_v2.instance.access_ip_v4

      user = "centos"

      private_key = file("${path.module}/mcs-home.pem")
    }

    inline = [
#      "sudo yum update -y",
      "sudo yum install -y yum-utils",
      "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
      "sudo yum install -y docker-ce docker-ce-cli containerd.io",
      "sudo usermod -aG docker centos",
#      "exec sg docker newgrp `id -gn`",
      "sudo echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf",
      "sudo /sbin/sysctl -p",
      "sudo systemctl restart network",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "mkdir -p ~/gitlab/{data,logs,config,postgresql}"
    ]
  }

  provisioner "file" {
    connection {
      host = openstack_compute_instance_v2.instance.access_ip_v4

      user = "centos"

      private_key = file("${path.module}/mcs-home.pem")
    }
    source      = "docker-compose.yml"
    destination = "~/gitlab"
  }
}

output "instances" {
  value = openstack_compute_instance_v2.instance.access_ip_v4
}

