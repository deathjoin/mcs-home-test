variable "mcs_login" {
  description = "The username for mcs account"
  type        = string
  sensitive   = true
}

variable "mcs_password" {
  description = "The password for mcs account"
  type        = string
  sensitive   = true
}

variable "mcs_project_id" {
  type        = string
  sensitive   = true
  description = "The project id for mcs account"
}
