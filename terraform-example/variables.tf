variable "env" {
  description = "Project environment"
  type        = string
  default     = "rnd"
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
    "owner" = "trungtin"
    "iac"   = "terraform"
  }
}
