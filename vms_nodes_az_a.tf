##########################################################################
### MySQL Nodes                                                        ###
##########################################################################


### Availability Zone A :: VMs #########################################

resource "aws_instance" "mysql_az_a" {

  count = try(var.cluster.nodes.az_a.count, 0)

  ami                         = var.cluster.nodes.ami
  subnet_id                   = var.cluster.nodes.az_a.subnet_id
  instance_type               = var.cluster.nodes.instance_type
  monitoring                  = var.cluster.nodes.monitoring
  source_dest_check           = var.cluster.nodes.source_dest_check
  key_name                    = var.cluster.nodes.default_ssh_key_name
  vpc_security_group_ids      = var.cluster.nodes.az_a.vpc_security_group_ids
  user_data                   = var.cluster.nodes.user_data
  associate_public_ip_address = false

  tags = merge(
    {
      Name = "${var.cluster.service_name}-${var.cluster.name}-a-${count.index + 1}-node"
      Role = "MySQL Node"
    },
    try(var.cluster.nodes.az_a.tags, {}),
    try(var.cluster.nodes.tags, {}),
    try(var.cluster.tags, {}),
  )

  root_block_device {
    volume_size           = var.cluster.nodes.root_block_device.volume_size
    delete_on_termination = var.cluster.nodes.root_block_device.delete_on_termination
    volume_type           = var.cluster.nodes.root_block_device.volume_type

    tags = merge(
      {
        Name = "root disk for ${var.cluster.service_name}-${var.cluster.name}-a-${count.index + 1}-data"
        Role = "Root Disk"
      },
      try(var.cluster.nodes.az_a.tags, {}),
      try(var.cluster.nodes.tags, {}),
      try(var.cluster.tags, {}),
    )
  }
}

### Availability Zone A :: Disks :: Data ##################################

resource "aws_ebs_volume" "mysql_az_a_data" {

  count = try(var.cluster.nodes.az_a.count, 0)

  availability_zone = var.cluster.availability_zones.az_a
  size              = var.cluster.nodes.data_volume.volume_size
  type              = var.cluster.nodes.data_volume.volume_type
  tags = merge(
    {
      Name  = "data disk for ${var.cluster.service_name}-${var.cluster.name}-data-a-${count.index + 1}"
      Usage = "data",
    },
    try(var.cluster.nodes.az_a.tags, {}),
    try(var.cluster.nodes.tags, {}),
    try(var.cluster.tags, {}),
  )
}

resource "aws_volume_attachment" "mysql_az_a_data_attachment" {
  count = try(var.cluster.nodes.az_a.count, 0)

  volume_id   = element(aws_ebs_volume.mysql_az_a_data[*].id, count.index)
  instance_id = element(aws_instance.mysql_az_a[*].id, count.index)
}


### Availability Zone A :: Disks :: Logs ##################################

resource "aws_ebs_volume" "mysql_az_a_logs" {

  count = try(var.cluster.nodes.az_a.count, 0)

  availability_zone = var.cluster.availability_zones.az_a
  size              = var.cluster.nodes.logs_volume.volume_size
  type              = var.cluster.nodes.logs_volume.volume_type
  tags = merge(
    {
      Name  = "logs disk for ${var.cluster.service_name}-${var.cluster.name}-a-${count.index + 1}"
      Usage = "logs",
    },
    try(var.cluster.nodes.az_a.tags, {}),
    try(var.cluster.nodes.tags, {}),
    try(var.cluster.tags, {}),
  )
}

resource "aws_volume_attachment" "mysql_az_a_logs_attachment" {
  count = try(var.cluster.nodes.az_a.count, 0)

  volume_id   = element(aws_ebs_volume.mysql_az_a_logs[*].id, count.index)
  instance_id = element(aws_instance.mysql_az_a[*].id, count.index)
}
