variable "do_token" {}
variable "ssh_key_ids" {
  default = []
  type = list(number)
}

variable "project_uuid" {
  default = ""
}

variable "droplet_count" {
  default = 2
}
variable "droplet_names" {
  default = ["stack-droplet-0", "stack-droplet-1"]
  type = list(string)
}
variable "image" { 
  // Can be either image slug or ID
  default = "django-20-04"
}
variable "droplet_size_slug" {
  default = "s-1vcpu-1gb"
}

variable "lb_count" {
  default = 1
}

variable "lb_name" {
  default = "stack-lb"
}

variable "create_db" {
  default = false
}
variable "db_engine" {
  default = "pg"
}
variable "db_engine_version" {
  default = "12"
}
variable "db_cluster_name" {
  default = "stack-db-cluster"
}
variable "db_size_slug" {
  default = "db-s-1vcpu-1gb"
}

variable "tag_list" {
  default = []
  type = list(string)
}

variable "region" {
  default = "nyc3"
}

variable "project_url" {
  default = ""
}

variable "api_host" {
  default = "https://api.digitalocean.com"
}
