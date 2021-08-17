# If applied as is, this template would put up an empty Nginx site at https://k8s-template.dev.dorf.world/

locals {
  app_name = "k8s-template" # Change to your-thing
  host = "k8s-template.dev.dorf.world" # Change to your-thing.dev.dorf.world
}

terraform {
  backend "remote" {
    organization = "ffddorf-dev"

    workspaces {
      prefix = "app-k8s-template-" # Change to app-your-thing-
    }
  }
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = "app-${local.app_name}"
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name = local.app_name
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      k8s_app = local.app_name
    }
  }
  spec {
    selector {
      match_labels = {
        k8s_app = local.app_name
      }
    }
    template {
      metadata {
        labels = {
          k8s_app = local.app_name
        }
      }
      spec {
        container {
          name = local.app_name
          image = "nginx"
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name = local.app_name
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      service = local.app_name
    }
  }
  spec {
    port {
      name = "http"
      port = 80
      target_port = 80
    }
    selector = {
      k8s_app = local.app_name
    }
  }
}

resource "kubernetes_ingress" "app" {
  metadata {
    name = local.app_name
    namespace = kubernetes_namespace.app.metadata[0].name
    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
      "kubernetes.io/ingress.class" = "traefik"
      "kubernetes.io/tls-acme" = "true"
      "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
      "traefik.ingress.kubernetes.io/router.tls" = "true"
    }
  }
  spec {
    rule {
      host = local.host
      http {
        path {
          path = "/"
          backend {
            service_name = local.app_name
            service_port = 80
          }
        }
      }
    }
    tls {
      secret_name = "letsencrypt-cert"
      hosts = [local.host]
    }
  }
}
