variable "yc_token" {
    type = string
    sensitive = true
}

variable "yc_zone" {
    type = string
}

variable "os_image" {
    type = string
}

variable "yc_folder" {
    type = string
}

variable "yc_user" {
    type = string
}

variable "db_name" {
  type      = string
  sensitive = true
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type = string
}

variable "domain_name" {
  type = string
}