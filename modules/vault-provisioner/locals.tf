locals {
  envs = toset([for env, _ in var.vault_authorized_environments : env])
}