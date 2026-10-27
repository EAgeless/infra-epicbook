variable "location" {
  description = "Azure region for bootstrap resources."
  type        = string
  default     = "westus2"
}

variable "vm_size" {
  description = "Agent VM size."
  type        = string
  default     = "Standard_F1ams_v7"
}

variable "admin_username" {
  description = "Linux administrator username."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Local path to the existing SSH public key."
  type        = string
  default     = "~/.ssh/evangeline-azagent-key.pub"
}

variable "admin_cidr" {
  description = "Approved administrator IPv4 address with /32."
  type        = string

  validation {
    condition = (
      can(cidrnetmask(var.admin_cidr)) &&
      endswith(var.admin_cidr, "/32")
    )
    error_message = "Provide a single IPv4 address with /32."
  }
}
