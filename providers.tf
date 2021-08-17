data "terraform_remote_state" "kubernetes" {
  backend = "remote"

  config = {
    organization = "ffddorf-dev"
    workspaces = {
      name = "k3os-on-proxmox"
    }
  }
}

locals {
  kubernetes_host    = "${data.terraform_remote_state.kubernetes.outputs.dns_records[0].name}.freifunk-duesseldorf.de"
  kubernetes_api_url = "https://${local.kubernetes_host}:8443"
}

provider "kubernetes" {
  host  = local.kubernetes_api_url
  token = data.terraform_remote_state.kubernetes.outputs.k8s_api_token
}

provider "helm" {
  kubernetes {
    host  = local.kubernetes_api_url
    token = data.terraform_remote_state.kubernetes.outputs.k8s_api_token
  }
}
