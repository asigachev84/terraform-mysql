output "mysql_inventory" {
  value = {
    mysql = {
      children = {
        mysql_nodes = {
          hosts = merge(
            {
              for i in range(length(aws_instance.mysql_az_a)) :
              aws_instance.mysql_az_a[i].tags.Name => {
                ansible_host = aws_instance.mysql_az_a[i].private_ip
                ebs_volume_id = {
                  data = element(aws_ebs_volume.mysql_az_a_data[*].id, i)
                  logs = element(aws_ebs_volume.mysql_az_a_logs[*].id, i)
                }
              }
            },
            {
              for i in range(length(aws_instance.mysql_az_b)) :
              aws_instance.mysql_az_b[i].tags.Name => {
                ansible_host = aws_instance.mysql_az_b[i].private_ip
                ebs_volume_id = {
                  data = element(aws_ebs_volume.mysql_az_b_data[*].id, i)
                  logs = element(aws_ebs_volume.mysql_az_b_logs[*].id, i)
                }
              } if length(aws_instance.mysql_az_b) > 0
            },
            {
              for i in range(length(aws_instance.mysql_az_c)) :
              aws_instance.mysql_az_c[i].tags.Name => {
                ansible_host = aws_instance.mysql_az_c[i].private_ip
                ebs_volume_id = {
                  data = element(aws_ebs_volume.mysql_az_c_data[*].id, i)
                  logs = element(aws_ebs_volume.mysql_az_c_logs[*].id, i)
                }
              } if length(aws_instance.mysql_az_c) > 0
            }
          )
        },
      }
    }
  }
  description = "Inventory file for MySQL nodes in Ansible format."
}
