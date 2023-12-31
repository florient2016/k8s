variable "subnet" {
  default = {
    subnet1 ={
      name = "subnet1"
      addPrefix = "10.0.1.0/24"
    }
    subnet2 = {
      name = "subnet2"
      addPrefix = "10.0.2.0/24"
    }
  }
}

variable "listSubnet" {
  type = list(string)
  default = ["10.0.1.0/24","10.0.2.0/24"]
}

variable "vpc_net" {
  default = "10.0.0.0/16"
}

variable "Subent-net" {
  default = "172.31.0.0/16"
}

variable "allPublic" {
  type = string
  default = "0.0.0.0/0"
}

variable "instanceAmi" {
  type = string
  default = "ami-0b0af3577fe5e3532"
}

## Define your key variable
variable "generated_key_name" {
  type        = string
  default     = "myKey1"
  description = "Key-pair generated by Terraform"
}