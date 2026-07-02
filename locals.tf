locals {
  special_identities = [
    "allUsers",
    "allAuthenticatedUsers",
  ]

  iam_member_prefix_pattern = "^(allUsers|allAuthenticatedUsers|user:|serviceAccount:|group:|domain:|projectOwner:|projectEditor:|projectViewer:|principal:|principalSet:)"

  iam_binding_sets = concat(
    [for role, members in var.iam_bindings : { role = role, members = members }],
    [for role, members in var.bucket.iam_bindings : { role = role, members = members }],
  )

  flat_bindings = flatten([
    for binding in local.iam_binding_sets : [
      for member in binding.members : {
        role = binding.role
        member = (
          contains(local.special_identities, member) ? member :
          can(regex(local.iam_member_prefix_pattern, member)) ? member :
          strcontains(member, "@") ? "serviceAccount:${member}" :
          "serviceAccount:${member}@${var.project}.iam.gserviceaccount.com"
        )
      }
    ]
  ])

  grouped_bindings = {
    for binding in local.flat_bindings :
    "${binding.role}__${binding.member}" => binding
  }

  labels = merge(var.labels, var.bucket.labels)
}
