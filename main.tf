module "vpc"{
    source = "./modules/vpc"
    vpc_name = var.vpc_name
    cidr_block = var.cidr_block
    public1_subnet_cidr = var.public1_subnet_cidr
    public2_subnet_cidr = var.public2_subnet_cidr
    private1_subnet_cidr = var.private1_subnet_cidr
    private2_subnet_cidr = var.private2_subnet_cidr
    project_name_env = var.project_name_env
    region = var.region
}

module "eks"{
    source = "./modules/eks"
    region = var.region
    cluster_name = var.cluster_name
    eks-node = var.eks-node
    # sg_id = module.vpc.sg_id
    private1_subnet_id = module.vpc.private1_subnet_id
    private2_subnet_id = module.vpc.private2_subnet_id
    vpc_id = module.vpc.vpc_id
    desired_nodes = var.desired_nodes
    min_nodes = var.min_nodes
    max_nodes = var.max_nodes
    project_name_env = var.project_name_env
    data_instance_types = var.data_instance_types
    service_instance_types = var.service_instance_types
    capacity_type = var.capacity_type
    ami_type = var.ami_type
    public_subnets = [module.vpc.public1_subnet_id, module.vpc.public2_subnet_id]
    # public1_subnet_id = module.vpc.public1_subnet_id
    # public2_subnet_id = module.vpc.public2_subnet_id
}
