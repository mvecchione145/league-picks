# An A record for the app in an existing public hosted zone.
#
# The zone is looked up, not declared: mvecc.dev holds records for other things
# and its nameservers are already lodged with the registrar. Creating the zone
# here would mint a second one with a different NS set, which resolves nothing
# until the registrar is repointed — and `terraform destroy` would then take
# every unrelated record in it down with this box.

data "aws_route53_zone" "root" {
  count = var.domain_name == null ? 0 : 1

  name         = var.hosted_zone_name
  private_zone = false
}

resource "aws_route53_record" "app" {
  count = var.domain_name == null ? 0 : 1

  zone_id = data.aws_route53_zone.root[0].zone_id
  name    = var.domain_name
  type    = "A"

  # Short enough to move the app to another address within the hour, long
  # enough that a resolver is not asking on every page load. Nothing here is
  # behind a load balancer, so there is no alias record to use instead.
  ttl     = 300
  records = [local.public_ip]

  # Left at the default: an existing record of this name is an error rather
  # than something to silently take over. If this stack should own it, delete
  # the old record or `terraform import` it first.
  allow_overwrite = false

  lifecycle {
    precondition {
      condition     = var.allocate_eip
      error_message = <<-EOT
        A record pointing at an ephemeral instance address goes stale on the
        next stop/start, which is the breakage allocate_eip exists to prevent.
        Set allocate_eip = true, or domain_name = null to skip the record.
      EOT
    }
  }
}
