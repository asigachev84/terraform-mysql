

variable "cluster" {
  type = object({
    name         = string
    tags         = optional(map(string), {})
    service_name = optional(string, "mysql")

    # Availability zones #############################################
    availability_zones = object({
      az_a = string
      az_b = optional(string)
      az_c = optional(string)
    })

    # Node settings ##################################################
    nodes = object({
      # Node settings :: Common ######################################
      ami                  = string
      default_ssh_key_name = string
      tags                 = optional(map(string), {})

      # Node settings :: Data nodes ##########################
      source_dest_check = optional(bool, false)
      monitoring        = optional(bool, true)
      user_data         = optional(string, "")
      instance_type     = string
      tags              = optional(map(string), {})

      # Node settings :: Data nodes :: Disks ###############
      root_block_device = object({
        volume_size           = number
        delete_on_termination = optional(bool, true)
        volume_type           = string
        tags                  = optional(map(string), {})
      })

      data_volume = optional(
        object({
          volume_size = number
          volume_type = string
        })
      )

      logs_volume = optional(
        object({
          volume_size = number
          volume_type = string
        })
      )


      # Node settings :: Data nodes :: Per-AZ settings #####
      az_a = object({
        count                  = number
        subnet_id              = string
        vpc_security_group_ids = list(string)
      })
      az_b = optional(
        object({
          count                  = number
          subnet_id              = string
          vpc_security_group_ids = list(string)
        })
      )
      az_c = optional(
        object({
          count                  = number
          subnet_id              = string
          vpc_security_group_ids = list(string)
        })
      )
    })
  })
}

