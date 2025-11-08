module "vpc" {
  source       = "./modules/vpc"
  gow          = "secure-webapp"
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}


module "private_subnets" {
  source             = "./modules/private_subnet"
  gow                 = "secure-webapp"
  vpc_id             = module.vpc.vpc_id
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.3.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

module "public_subnets" {
  source             = "./modules/public_subnet"
  gow                 = "secure-webapp"
  vpc_id             = module.vpc.vpc_id
  public_subnet_cidrs = ["10.0.0.0/24", "10.0.2.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

module "igw" {
  source       = "./modules/igw"
  gow          = "secure-webapp"
  vpc_id       = module.vpc.vpc_id
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

module "nat_gateway" {
  source           = "./modules/nat_gateway"
  gow              = "secure-webapp"
  public_subnet_id = module.public_subnets.public_subnet_ids[0]
  dependency_igw   = module.igw.igw_id
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

module "route_tables" {
  source             = "./modules/routing_tables"
  gow       = "secure-webapp"
  vpc_id             = module.vpc.vpc_id
  internet_gateway_id = module.igw.igw_id
  nat_gateway_id      = module.nat_gateway.nat_gateway_id
  public_subnet_ids   = module.public_subnets.public_subnet_ids
  private_subnet_ids  = module.private_subnets.private_subnet_ids
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

module "sg_public_alb" {
  source       = "./modules/security_group"
  gow          = "secure-webapp"
  vpc_id       = module.vpc.vpc_id
  sg_name      = "public-alb"
  sg_description = "Allow inbound HTTP/HTTPS from Internet to Public ALB"

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP from Internet"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTPS from Internet"
    }
  ]

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

module "sg_proxy" {
  source    = "./modules/security_group"
  gow          = "secure-webapp"
  vpc_id       = module.vpc.vpc_id
  sg_name      = "proxy"
  sg_description = "Allow inbound traffic from Public ALB"

  ingress_rules = [
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = module.sg_public_alb.security_group_id
      description              = "Allow traffic from Public ALB"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] 
      description = "ALLOW ALL for local SSH access and provisioning"
    }
  ]

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

module "sg_internal_alb" {
  source       = "./modules/security_group"
  gow          = "secure-webapp"
  vpc_id       = module.vpc.vpc_id
  sg_name      = "internal-alb"
  sg_description = "Allow traffic from proxies and route to backend"
  ingress_rules = [
    {
      from_port                = 5000
      to_port                  = 5000
      protocol                 = "tcp"
      source_security_group_id = module.sg_proxy.security_group_id
      description              = "Allow from proxy SG"
    },
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = module.sg_proxy.security_group_id
      description              = "Allow from proxy SG"
    }
  ]
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

module "sg_backend" {
  source       = "./modules/security_group"
  gow          = "secure-webapp"
  vpc_id       = module.vpc.vpc_id
  sg_name      = "backend"
  sg_description = "Allow inbound traffic only from the Internal ALB"

  ingress_rules = [
    {
      from_port                = 5000               
      to_port                  = 5000
      protocol                 = "tcp"
      source_security_group_id = module.sg_internal_alb.security_group_id 
      description              = "Allow traffic from Internal ALB only"
    },
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      source_security_group_id = module.sg_proxy.security_group_id 
      description              = "Allow SSH from Proxy/Bastion Host SG"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic (via NAT)"
    }
  ]

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
    Role        = "backend"
  }
}

module "alb_public" {
  source              = "./modules/load_balancer"
  gow                 = "secure-webapp"
  lb_name             = "public"
  vpc_id              = module.vpc.vpc_id
  internal            = false
  subnet_ids          = module.public_subnets.public_subnet_ids
  security_group_ids  = [module.sg_public_alb.security_group_id]
  listener_port       = 80
  listener_protocol   = "HTTP"
  target_port         = 80
  target_protocol     = "HTTP"
  health_check_path   = "/health"
  tags = {
    Environment = "dev"
    Type        = "Public"
  }
}

module "alb_internal" {
  source              = "./modules/load_balancer"
  gow                 = "secure-webapp"
  lb_name             = "internal"
  vpc_id              = module.vpc.vpc_id
  internal            = true
  subnet_ids          = module.private_subnets.private_subnet_ids
  security_group_ids  = [module.sg_internal_alb.security_group_id]
  tags = {
    Environment = "dev"
    Type        = "Internal"
  }
}


module "ec2_proxy" {
  source               = "./modules/ec2_proxy"
  gow                  = "secure-webapp"
  subnet_ids           = module.public_subnets.public_subnet_ids
  security_group_ids   = [module.sg_proxy.security_group_id]
  instance_count       = 2
  instance_type        = "t3.micro"
  key_name             = "my-keypair"
  internal_alb_dns_name = module.alb_internal.alb_dns_name
  ssh_private_key_path = "./modules/ec2_proxy/my-keypair.pem"
  tags = {
    Environment = "dev"
    Role        = "proxy"
    ManagedBy   = "Terraform"
  }
}

module "ec2_backend" {
  source               = "./modules/ec2_backend"
  gow                  = "secure-webapp"
  subnet_ids           = module.private_subnets.private_subnet_ids
  security_group_ids   = [module.sg_backend.security_group_id]
  instance_count       = 2
  instance_type        = "t3.micro"
  key_name             = "my-keypair"
  ssh_private_key_path = "./modules/ec2_backend/my-keypair.pem"
  local_backend_path   = "./webapp" 
  proxy_public_ip      = module.ec2_proxy.proxy_public_ips[0]
  tags = {
    Environment = "dev"
    Role        = "backend"
    ManagedBy   = "Terraform"
  }
}

module "alb_target_public" {
  source            = "./modules/alb_target"
  gow               = "secure-webapp"
  vpc_id            = module.vpc.vpc_id
  alb_arn           = module.alb_public.alb_arn
  tg_name           = "public-proxy"
  target_port       = 80
  target_protocol   = "HTTP"
  listener_port     = 80
  listener_protocol = "HTTP"
  health_check_path = "/healthcheck"
  instance_ids      = module.ec2_proxy.proxy_instance_ids
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
module "alb_target_internal" {
  source            = "./modules/alb_target"
  gow               = "secure-webapp"
  vpc_id            = module.vpc.vpc_id
  alb_arn           = module.alb_internal.alb_arn
  tg_name           = "internal-backend"
  target_port       = 5000
  target_protocol   = "HTTP"
  listener_port     = 80
  listener_protocol = "HTTP"
  health_check_path = "/"
  instance_ids      = module.ec2_backend.backend_instance_ids
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}