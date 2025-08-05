variable "project_id" {
    type = string
    description = "GCP project_id"
}

variable "region" {
    type = string
    description = "GCP region"
}

variable "zone" {
    type = string
    description = "zone GCP"
}

variable "credentials_json" {
    type = string
    description = "path to GCP file.json credentials"
}

variable "instance_name" {
    type = string
    description = "name vm"
}

variable "machine_type" {
    type = string
    description = "GCP machine_type"
}

variable "ssh_user" {
    type = string
    description = "user for SSH"
}

variable "public_key" {
    type = string
    description = "ssh public_key"
}