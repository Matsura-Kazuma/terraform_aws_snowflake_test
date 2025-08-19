variable "name" { type=string }
variable "image_scan_on_push" { type=bool, default=true }
variable "tags" { type=map(string) }
