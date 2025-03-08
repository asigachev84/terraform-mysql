# Terraform module for creating a set of MySQL nodes

## Sample cluster definition

```hcl
module "mysql_cluster" {
  source = "./modules/mysql"

  cluster = {
    name = "sockshop"


    tags = {
      ManagedBy   = "Terraform"
      Environment = "Pre-Production"
    }

    availability_zones = {
      az_a = "ru-msk-comp1p"
      az_b = "ru-msk-vol51"
      az_c = "ru-msk-vol52"
    }

    # Node settings ##################################################
    nodes = {
      ami                  = "cmi-DC1CBC52" # CentOS 9
      default_ssh_key_name = aws_key_pair.asigachev_ssh_key.id

      # Node settings :: Data nodes ##########################
      source_dest_check = false
      monitoring        = true
      user_data         = ""
      instance_type     = "c5.large"

      # Node settings :: Data nodes :: Disks ###############
      root_block_device = {
        volume_size           = 32
        delete_on_termination = true
        volume_type           = "st2"
        tags                  = {}
      }

      data_volume = {
        volume_size = 8
        volume_type = "st2"
      }

      logs_volume = {
        volume_size = 8
        volume_type = "st2"
      }

      # Node settings :: Config nodes :: Per-AZ settings ###########
      az_a = {
        count                  = 1
        subnet_id              = data.aws_subnet.default_subnet_cmp.id
        vpc_security_group_ids = local.default_security_groups_list
      }
      az_b = {
        count                  = 1
        subnet_id              = data.aws_subnet.default_subnet_vol51.id
        vpc_security_group_ids = local.default_security_groups_list
      }
      az_c = {
        count                  = 1
        subnet_id              = data.aws_subnet.default_subnet_vol52.id
        vpc_security_group_ids = local.default_security_groups_list
      }
    }
  }
}
```

## Ansible Inventory

Module `outputs.tf` generates outputs that can easily be converted to Ansible
static inventory file.

If your module was referred in the main Terraform configuration as `mysql_cluster`:

```hcl
module "mysql_cluster" {
  source = "./modules/mysql"
```

Then add its outputs to your main Terraform configuration `outputs.tf`:

```hcl
output "mysql_cluster" {
  value = module.mysql_cluster.mysql_inventory
}
```

So after `terraform apply` execution you can get the Ansible inventory file
with the following command:

```shell
terraform output --json | yq -P '.mysql_cluster.value'
```

## Notes on manifests code
