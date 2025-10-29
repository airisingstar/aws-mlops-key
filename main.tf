# ------------------------------------------------------------
# Entry point: provisions one full environment by composing modules
# ------------------------------------------------------------
module "environment" {
  source       = "./modules/environment"
  name_prefix  = var.name_prefix
  region       = var.region
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
}
