##########################################################################
### MySQL Nodes                                                        ###
##########################################################################


### Availability Zone C :: VMs #########################################

resource "aws_instance" "mysql_az_c" {

  count = try(var.cluster.nodes.az_c.count, 0)

  ami                         = var.cluster.nodes.ami
  subnet_id                   = var.cluster.nodes.az_c.subnet_id
  instance_type               = var.cluster.nodes.instance_type
  monitoring                  = var.cluster.nodes.monitoring
  source_dest_check           = var.cluster.nodes.source_dest_check
  key_name                    = var.cluster.nodes.default_ssh_key_name
  vpc_security_group_ids      = var.cluster.nodes.az_c.vpc_security_group_ids
  user_data                   = var.cluster.nodes.user_data
  associate_public_ip_address = false

  tags = merge(
    {
      Name = "${var.cluster.service_name}-${var.cluster.name}-c-${count.index + 1}-node"
      Role = "MySQL Node"
    },
    try(var.cluster.nodes.az_c.tags, {}),
    try(var.cluster.nodes.tags, {}),
    try(var.cluster.tags, {}),
  )

  root_block_device {
    volume_size           = var.cluster.nodes.root_block_device.volume_size
    delete_on_termination = var.cluster.nodes.root_block_device.delete_on_termination
    volume_type           = var.cluster.nodes.root_block_device.volume_type

    tags = merge(
      {
        Name = "root disk for ${var.cluster.service_name}-${var.cluster.name}-c-${count.index + 1}-data"
        Role = "Root Disk"
      },
      try(var.cluster.nodes.az_c.tags, {}),
      try(var.cluster.nodes.tags, {}),
      try(var.cluster.tags, {}),
    )
  }
}

### Availability Zone C :: Disks :: Data ##################################

resource "aws_ebs_volume" "mysql_az_c_data" {

  count = try(var.cluster.nodes.az_c.count, 0)

  availability_zone = var.cluster.availability_zones.az_c
  size              = var.cluster.nodes.data_volume.volume_size
  type              = var.cluster.nodes.data_volume.volume_type
  tags = merge(
    {
      Name = "data disk for ${var.cluster.service_name}-${var.cluster.name}-data-c-${count.index + 1}"
    },
    try(var.cluster.nodes.az_c.tags, {}),
    try(var.cluster.nodes.tags, {}),
    try(var.cluster.tags, {}),
  )
}

resource "aws_volume_attachment" "mysql_az_c_data_attachment" {
  count = try(var.cluster.nodes.az_c.count, 0)

  volume_id   = element(aws_ebs_volume.mysql_az_c_data[*].id, count.index)
  instance_id = element(aws_instance.mysql_az_c[*].id, count.index)
}


### Availability Zone C :: Disks :: Logs ##################################

resource "aws_ebs_volume" "mysql_az_c_logs" {

  count = try(var.cluster.nodes.az_c.count, 0)

  availability_zone = var.cluster.availability_zones.az_c
  size              = var.cluster.nodes.logs_volume.volume_size
  type              = var.cluster.nodes.logs_volume.volume_type
  tags = merge(
    {
      Name = "logs disk for ${var.cluster.service_name}-${var.cluster.name}-c-${count.index + 1}"
    },
    try(var.cluster.nodes.az_c.tags, {}),
    try(var.cluster.nodes.tags, {}),
    try(var.cluster.tags, {}),
  )
}

resource "aws_volume_attachment" "mysql_az_c_logs_attachment" {
  count = try(var.cluster.nodes.az_c.count, 0)

  # device_name = "Disk2"
  volume_id   = element(aws_ebs_volume.mysql_az_c_logs[*].id, count.index)
  instance_id = element(aws_instance.mysql_az_c[*].id, count.index)
}

