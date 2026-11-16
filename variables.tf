# variables.tf - configurable parameters of the infrastructure
# (change a value here, push, and the pipeline re-deploys)

# --- Database variables (PostgreSQL) ---
variable "db_name" {
  description = "Name of the PostgreSQL database."
  type        = string
  default     = "devops_db"
}

variable "db_user" {
  description = "PostgreSQL user name."
  type        = string
  default     = "devops_user"
}

variable "db_password" {
  description = "PostgreSQL password (simulated lab value - in production use a secret, e.g. TF_VAR_db_password)."
  type        = string
  default     = "strongpassword123"
  sensitive   = true # hidden in plan/apply output
}

variable "db_port_external" {
  description = "Port on the host for PostgreSQL (mapped to 5432 inside the container). Change it if 5432 is already used."
  type        = number
  default     = 5432
}

# --- Application variables ---
variable "app_port_external" {
  description = "External port of the web application (mapped to port 80 inside the container)."
  type        = number
  default     = 8080
}
