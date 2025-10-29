# Optional thin wrapper if you prefer per-env applies
module "prod_env" {
  source       = "../modules/environment"
  name_prefix  = "prod"
  region       = var.region
  environment  = "prod"
  vpc_cidr     = "10.30.0.0/16"
}
