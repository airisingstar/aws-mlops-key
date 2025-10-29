# Optional thin wrapper if you prefer per-env applies
module "staging_env" {
  source       = "../modules/environment"
  name_prefix  = "staging"
  region       = var.region
  environment  = "staging"
  vpc_cidr     = "10.22.0.0/16"
}
