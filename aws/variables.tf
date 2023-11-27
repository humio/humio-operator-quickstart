variable "region" {
  type    = string
  default = "us-west-2"
}
variable "humio_instance_type" {
  type    = string
  default = "i3.large" # Instance should have local NVME
}
variable "humio_instance_count" {
  type    = number
  default = 3
}
variable "kafka_instance_type" {
  type    = string
  default = "kafka.m5.large"
}
variable "kafka_instance_count" {
  type    = number
  default = 3
}
variable "kafka_version" {
  type    = string
  default = "2.8.1"
}
variable "kafka_volume_size" {
  type    = number
  default = 100
}
variable "humio_data_dir" {
  type    = string
  default = "/mnt/disks/vol1"
}
variable "humio_data_dir_owner_uuid" {
  type    = number
  default = 65534
}
variable "user_data_script" {
  type    = string
  default = "user-data.sh.tmpl"
}
variable "namespace" {
  type    = string
  default = "logging"
}
variable "service_account_name" {
  type    = string
  default = "humio-quickstart-humio"
}

variable "environment" {
  type    = string
  default = "development"
}
variable "owner" {
  type    = string
  default = "humio"
}

variable "cluster_name" {
  type    = string
  default = "humio-quickstart-example"
}
