variable "ssh_public_key" {
  type        = string
  description = "SSH public key used to log in as root."
}

variable "stud_count" {
  type        = number
  default     = 10
  description = "Student teams. Slug stud_team<N>-pwnbox."

  validation {
    condition     = var.stud_count >= 0 && var.stud_count <= 50
    error_message = "stud_count must be between 0 and 50."
  }
}

variable "work_count" {
  type        = number
  default     = 12
  description = "Work teams. Slug work_team<N>-pwnbox."

  validation {
    condition     = var.work_count >= 0 && var.work_count <= 50
    error_message = "work_count must be between 0 and 50."
  }
}

variable "location" {
  type        = string
  default     = "fsn1"
  description = "Hetzner location: fsn1, nbg1, hel1, ash, sin, ..."
}

variable "server_type" {
  type        = string
  default     = "cx52"
  description = "32 GB / 320 GB class. Three desktops do not fit on a small disk."
}

variable "image" {
  type    = string
  default = "ubuntu-24.04"
}

variable "linux_image" {
  type        = string
  default     = "qemux/qemu"
  description = "Dockur Linux VM image (dockur/qemu)."
}

variable "linux_boot" {
  type        = string
  default     = "ubuntu"
  description = "Linux guest downloaded by qemux/qemu. ubuntu is Ubuntu Desktop."
}

variable "windows_image" {
  type    = string
  default = "dockurr/windows"
}

variable "windows_version" {
  type        = string
  default     = "11"
  description = "Dockur Windows VERSION value, such as 11 or 10."
}

variable "linux_ram" {
  type    = string
  default = "4G"
}

variable "windows_ram" {
  type    = string
  default = "8G"
}

variable "linux_cpus" {
  type    = string
  default = "2"
}

variable "windows_cpus" {
  type    = string
  default = "4"
}

variable "linux_disk" {
  type    = string
  default = "64G"
}

variable "windows_disk" {
  type    = string
  default = "64G"
}
