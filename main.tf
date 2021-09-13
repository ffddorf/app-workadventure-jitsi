variable "PUBLIC_IP_ADDRESS" {
  type = string
  default = "45.151.166.29"
}

variable "JVB_PORT" {
  type = string
  default = "10000"
}

locals {
  APP_NAME = "workadventure-jitsi"
  APP_HOST = "jitsi.dev.dorf.world"
  JICOFO_AUTH_USER = "focus"
  JVB_AUTH_USER = "jvb"
  JVB_BREWERY_MUC = "jvbbrewery"
  JVB_TCP_HARVESTER_DISABLED = "true"
  TZ = "Europe/Berlin"
  XMPP_AUTH_DOMAIN = "auth.meet.jitsi"
  XMPP_DOMAIN = "meet.jitsi"
  XMPP_INTERNAL_MUC_DOMAIN = "internal-muc.meet.jitsi"
  XMPP_MUC_DOMAIN = "muc.meet.jitsi"
  XMPP_SERVER = "localhost"
}

terraform {
  backend "remote" {
    organization = "ffddorf-dev"

    workspaces {
      prefix = "app-workadventure-jitsi-"
    }
  }
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = "app-${local.APP_NAME}"
  }
}

resource "random_string" "JICOFO_COMPONENT_SECRET" {
  length = 16
}

resource "random_string" "JICOFO_AUTH_PASSWORD" {
  length = 16
}

resource "random_string" "JVB_AUTH_PASSWORD" {
  length = 16
}

resource "kubernetes_secret" "app" {
  metadata {
    name = local.APP_NAME
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  data = {
    JICOFO_COMPONENT_SECRET = random_string.JICOFO_COMPONENT_SECRET.result
    JICOFO_AUTH_PASSWORD = random_string.JICOFO_AUTH_PASSWORD.result
    JVB_AUTH_PASSWORD = random_string.JVB_AUTH_PASSWORD.result
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name = local.APP_NAME
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      k8s_app = local.APP_NAME
    }
  }
  spec {
    selector {
      match_labels = {
        k8s_app = local.APP_NAME
      }
    }
    strategy {
      type = "Recreate"
    }
    template {
      metadata {
        labels = {
          k8s_app = local.APP_NAME
        }
      }
      spec {
        container {
          name = "jicofo"
          image = "jitsi/jicofo"
          env {
            name = "XMPP_SERVER"
            value = local.XMPP_SERVER
          }
          env {
            name = "XMPP_DOMAIN"
            value = local.XMPP_DOMAIN
          }
          env {
            name = "XMPP_AUTH_DOMAIN"
            value = local.XMPP_AUTH_DOMAIN
          }
          env {
            name = "XMPP_INTERNAL_MUC_DOMAIN"
            value = local.XMPP_INTERNAL_MUC_DOMAIN
          }
          env {
            name = "JICOFO_COMPONENT_SECRET"
            value_from {
              secret_key_ref {
                name = local.APP_NAME
                key = "JICOFO_COMPONENT_SECRET"
              }
            }
          }
          env {
            name = "JICOFO_AUTH_USER"
            value = local.JICOFO_AUTH_USER
          }
          env {
            name = "JICOFO_AUTH_PASSWORD"
            value_from {
              secret_key_ref {
                name = local.APP_NAME
                key = "JICOFO_AUTH_PASSWORD"
              }
            }
          }
          env {
            name = "TZ"
            value = local.TZ
          }
          env {
            name = "JVB_BREWERY_MUC"
            value = local.JVB_BREWERY_MUC
          }
        }
        container {
          name = "prosody"
          image = "jitsi/prosody"
          env {
            name = "XMPP_DOMAIN"
            value = local.XMPP_DOMAIN
          }
          env {
            name = "XMPP_AUTH_DOMAIN"
            value = local.XMPP_AUTH_DOMAIN
          }
          env {
            name = "XMPP_MUC_DOMAIN"
            value = local.XMPP_MUC_DOMAIN
          }
          env {
            name = "XMPP_INTERNAL_MUC_DOMAIN"
            value = local.XMPP_INTERNAL_MUC_DOMAIN
          }
          env {
            name = "JICOFO_COMPONENT_SECRET"
            value_from {
              secret_key_ref {
                name = local.APP_NAME
                key = "JICOFO_COMPONENT_SECRET"
              }
            }
          }
          env {
            name = "JVB_AUTH_USER"
            value = local.JVB_AUTH_USER
          }
          env {
            name = "JVB_AUTH_PASSWORD"
            value_from {
              secret_key_ref {
                name = local.APP_NAME
                key = "JVB_AUTH_PASSWORD"
              }
            }
          }
          env {
            name = "JICOFO_AUTH_USER"
            value = local.JICOFO_AUTH_USER
          }
          env {
            name = "JICOFO_AUTH_PASSWORD"
            value_from {
              secret_key_ref {
                name = local.APP_NAME
                key = "JICOFO_AUTH_PASSWORD"
              }
            }
          }
          env {
            name = "TZ"
            value = local.TZ
          }
          env {
            name = "JVB_TCP_HARVESTER_DISABLED"
            value = local.JVB_TCP_HARVESTER_DISABLED
          }
          env {
            name = "PUBLIC_URL"
            value = "https://${local.APP_HOST}"
          }
        }
        container {
          name = "web"
          image = "jitsi/web"
          env {
            name = "XMPP_SERVER"
            value = local.XMPP_SERVER
          }
          env {
            name = "JICOFO_AUTH_USER"
            value = local.JICOFO_AUTH_USER
          }
          env {
            name = "XMPP_DOMAIN"
            value = local.XMPP_DOMAIN
          }
          env {
            name = "XMPP_AUTH_DOMAIN"
            value = local.XMPP_AUTH_DOMAIN
          }
          env {
            name = "XMPP_INTERNAL_MUC_DOMAIN"
            value = local.XMPP_INTERNAL_MUC_DOMAIN
          }
          env {
            name = "XMPP_BOSH_URL_BASE"
            value = "http://127.0.0.1:5280"
          }
          env {
            name = "XMPP_MUC_DOMAIN"
            value = local.XMPP_MUC_DOMAIN
          }
          env {
            name = "TZ"
            value = local.TZ
          }
          env {
            name = "JVB_TCP_HARVESTER_DISABLED"
            value = local.JVB_TCP_HARVESTER_DISABLED
          }
          env {
            name = "PUBLIC_URL"
            value = "https://${local.APP_HOST}"
          }
        }
        container {
          name = "jvb"
          image = "jitsi/jvb"
          env {
            name = "XMPP_SERVER"
            value = local.XMPP_SERVER
          }
          env {
            name = "DOCKER_HOST_ADDRESS"
            value = var.PUBLIC_IP_ADDRESS
          }
          env {
            name = "XMPP_DOMAIN"
            value = local.XMPP_DOMAIN
          }
          env {
            name = "XMPP_AUTH_DOMAIN"
            value = local.XMPP_AUTH_DOMAIN
          }
          env {
            name = "XMPP_INTERNAL_MUC_DOMAIN"
            value = local.XMPP_INTERNAL_MUC_DOMAIN
          }
          env {
            name = "JVB_STUN_SERVERS"
            value = "stun.l.google.com:19302,stun1.l.google.com:19302,stun2.l.google.com:19302"
          }
          env {
            name = "JICOFO_AUTH_USER"
            value = local.JICOFO_AUTH_USER
          }
          env {
            name = "JVB_TCP_HARVESTER_DISABLED"
            value = local.JVB_TCP_HARVESTER_DISABLED
          }
          env {
            name = "JVB_AUTH_USER"
            value = local.JVB_AUTH_USER
          }
          env {
            name = "JVB_PORT"
            value = var.JVB_PORT
          }
          env {
            name = "JVB_AUTH_PASSWORD"
            value_from {
              secret_key_ref {
                name = local.APP_NAME
                key = "JVB_AUTH_PASSWORD"
              }
            }
          }
          env {
            name = "JICOFO_AUTH_PASSWORD"
            value_from {
              secret_key_ref {
                name = local.APP_NAME
                key = "JICOFO_AUTH_PASSWORD"
              }
            }
          }
          env {
            name = "JVB_BREWERY_MUC"
            value = local.JVB_BREWERY_MUC
          }
          env {
            name = "TZ"
            value = local.TZ
          }
          env {
            name = "PUBLIC_URL"
            value = "https://${local.APP_HOST}"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name = local.APP_NAME
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      service = local.APP_NAME
    }
  }
  spec {
    selector = {
      k8s_app = local.APP_NAME
    }
    port {
      name = "http"
      port = 80
      target_port = 80
    }
  }
}

resource "kubernetes_service" "jvb" {
  metadata {
    name = "jvb"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      service = "jvb"
    }
    annotations = {
      "metallb.universe.tf/allow-shared-ip" = "default"
    }
  }
  spec {
    type = "LoadBalancer"
    selector = {
      k8s_app = local.APP_NAME
    }
    load_balancer_ip = var.PUBLIC_IP_ADDRESS
    port {
      protocol = "UDP"
      port = var.JVB_PORT
      target_port = var.JVB_PORT
    }
  }
}

resource "kubernetes_ingress" "app" {
  metadata {
    name = local.APP_NAME
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
      host = local.APP_HOST
      http {
        path {
          path = "/"
          backend {
            service_name = local.APP_NAME
            service_port = 80
          }
        }
      }
    }
    tls {
      secret_name = "letsencrypt-cert"
      hosts = [local.APP_HOST]
    }
  }
}
