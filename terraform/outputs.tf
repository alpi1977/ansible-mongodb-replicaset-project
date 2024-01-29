// Creation of the inventory file for Ansible
// The outputs will be the hostname in AWS format that the internal DNS can interpret
// and the internal IP

resource "local_file" "ansible_inventory" {
  content = templatefile ("inventory.tmpl",
    {
      ip_mongo_node1 = aws_instance.nodes[0].private_ip
      ip_mongo_node2 = aws_instance.nodes[1].private_ip
      ip_mongo_node3 = aws_instance.nodes[2].private_ip
    })
  filename = "../ansible/inventory"
}
