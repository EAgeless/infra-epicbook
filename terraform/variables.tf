variable "location" {
  description = "Azure deployment region."
  type        = string
  default     = "westus2"
}

variable "resource_group_name" {
  description = "Resource group for EpicBook application infrastructure."
  type        = string
  default     = "rg-epicbook-app"
}

variable "vm_size" {
  description = "Size for the frontend and backend VMs."
  type        = string
  default     = "Standard_F1ams_v7"
}

variable "admin_username" {
  description = "Linux VM administrator username."
  type        = string
  default     = "azureuser"
}

variable "admin_cidr" {
  description = "Approved administrator public IPv4 address with /32."
  type        = string

  validation {
    condition = (
      can(cidrnetmask(var.admin_cidr)) &&
      endswith(var.admin_cidr, "/32")
    )
    error_message = "Provide one administrator IPv4 address with /32."
  }
}

variable "agent_cidr" {
  description = "Approved pipeline-agent public IPv4 address with /32."
  type        = string
  default     = "4.154.170.125/32"

  validation {
    condition = (
      can(cidrnetmask(var.agent_cidr)) &&
      endswith(var.agent_cidr, "/32")
    )
    error_message = "Provide one pipeline-agent IPv4 address with /32."
  }
}

variable "backend_port" {
  description = "EpicBook application port."
  type        = number
  default     = 8080
}

variable "mysql_admin_username" {
  description = "MySQL administrator supplied by a secured pipeline variable."
  type        = string
  sensitive   = true
}

variable "mysql_admin_password" {
  description = "MySQL password supplied by a secret pipeline variable."
  type        = string
  sensitive   = true
}
