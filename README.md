## Terraform-AWS-VPC

This repo contains a Terraform module which can configure AWS VPCs which utilize multiple availability zones with a common 3-tier (public/app/data) subnet split in each zone as per configuration variables (which can be found in the variables.tf file). Default values exist for the us-east-2 and us-west-2 regions. This module is intended merely as a demonstration and **not** the fullest expression of what is possible with Terraform in relation to VPCs (for example, one may wish to add a variety of capabilities such as the dynamic generation of CIDR blocks, the configuration of network ACLs, etc).

<p>&nbsp;</p>

## How To Use:

**As A Module**

As a module, you can simply include it in your parent configuration like so:

```
module "vpc" {
  source = "github.com/gege56015/Terraform-AWS-VPC"

  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  vpc_region = "${var.vpc_region}"

}
```

Of course, you'll want to include all of the variables that you wish to change from the defaults.

**In Isolation**

You can also just use this Terraform configuration directly (i.e. not as a module in a larger configuration). To do this, simply follow the instructions below:

1. Clone the repository
2. Optionally add a backend (such as S3) for storing state remotely
3. From the repository's root directory, type "terraform init" (and be sure to add any "backend-config" options needed for any backend configuration that you added) to initialize state management
4. Optionally create and switch to a workspace/environment (e.g. "terraform workspace new development") 
5. From the same directory, type "terraform apply" and answer any prompts


