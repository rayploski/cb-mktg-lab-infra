packer {
  required_plugins {
    azure = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/azure"
    }
  }
}

variable "client_id"     {}
variable "client_secret" {}
variable "tenant_id"     {}
variable "subscription_id" {}
variable "resource_group_name" {
  default = "packer-images"
}
variable "location" {
  default = "East US"
}
variable "image_name" {
  default = "full-corestory-mktg-stack-image"
}

variable "username" {
  default = "csadmin"
}

source "azure-arm" "ubuntu" {
  client_id         = var.client_id
  client_secret     = var.client_secret
  tenant_id         = var.tenant_id
  subscription_id   = var.subscription_id

  managed_image_resource_group_name = var.resource_group_name
  managed_image_name                = var.image_name

  location            = var.location
  vm_size             = "Standard_B2s"
  os_type             = "Linux"
  image_publisher     = "Canonical"
  image_offer         = "0001-com-ubuntu-server-jammy"
  image_sku           = "22_04-lts-gen2"
  image_version       = "latest"
  ssh_username = var.username
}

build {
  name = "azure-full-cs-stack"

  sources = ["source.azure-arm.ubuntu"]

  provisioner "file" {
    source      = "./install.sh"
    destination = "/tmp/install.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/install.sh",
      "sudo /tmp/install.sh"
    ]
  }
}