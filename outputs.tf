# ------------------------------------------------------------
# Handy outputs printed after apply
# ------------------------------------------------------------
output "pipeline_name"  { value = module.environment.pipeline_name }
output "endpoint_name"  { value = module.environment.endpoint_name }
output "vpc_id"         { value = module.environment.vpc_id }
output "subnet_ids"     { value = module.environment.subnet_ids }
