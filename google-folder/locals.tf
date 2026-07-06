locals {
  org_policies = {
    for policy in var.org_policies :
    policy.constraint => policy
  }
}
