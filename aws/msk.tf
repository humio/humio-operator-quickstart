resource "aws_security_group" "msk" {
  vpc_id = module.vpc.vpc_id
}

resource "aws_kms_key" "kms" {
  description = "Key for ${var.cluster_name}"
}

resource "aws_msk_cluster" "msk" {
  cluster_name           = var.cluster_name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.kafka_instance_count

  broker_node_group_info {
    instance_type   = var.kafka_instance_type
    client_subnets  = module.vpc.private_subnets
    security_groups = [aws_security_group.msk.id]
    
    storage_info {
      ebs_storage_info {
        volume_size = var.kafka_volume_size
      }
    }
  }


  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.kms.arn

    encryption_in_transit {
      client_broker = "TLS"
    }
  }


}

resource "aws_security_group_rule" "allow_kafka_tls" {
  type                     = "ingress"
  from_port                = 9094
  to_port                  = 9094
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_msk.id
  security_group_id        = aws_security_group.msk.id
}

resource "aws_security_group_rule" "allow_zookeeper" {
  type                     = "ingress"
  from_port                = 2181
  to_port                  = 2181
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_msk.id
  security_group_id        = aws_security_group.msk.id
}


output "zookeeper_connect_string" {
  description = "Plain text connection host:port pairs"
  value       = aws_msk_cluster.msk.zookeeper_connect_string
}

output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value       = aws_msk_cluster.msk.bootstrap_brokers_tls
}
