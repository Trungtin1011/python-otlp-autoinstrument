variable "env" {
  description = "Project environment"
  type        = string
  default     = null
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "trungtin"
}

variable "tags" {
  description = "Tagging values"
  type        = map(string)
  default = {
    "Owner" = "trungtin"
    "iac"   = "terraform"
  }
}
