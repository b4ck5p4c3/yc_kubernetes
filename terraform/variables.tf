variable "zones" {
  type    = list(string)
  default = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
}

variable "kubeapi_port" {
  type = number 
  default = 8080
}
