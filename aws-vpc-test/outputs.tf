output "vpc_id" {
    value = module.vpc.vpc_id
}

output "public_subnets_list" {
  value = module.vpc.public_subnet_ids
}

output "igw_id" {
    value = module.vpc.ig_id
}