Terraform Control repo built following the pattern as outlined by [Charity Majors](https://charity.wtf/2016/03/30/terraform-vpc-and-why-you-want-a-tfstate-file-per-env/)

TLDR, but really, go read the post, it's way better then what I'm going to write here..


### To create a new repo using the terraform-reference repo.

- Clone the repo `git clone https://github.com/FitnessKeeper/terraform-reference`
- Edit .env in the root of the repo, in particular make sure you add a TF_PROJECT_NAME
- Initialize variables.tf, this only needs to be done once, when the repo is created run `./init-variables.tf.sh`
- Edit variables.tf to reflect your new service



### To use an environment in the control repo
- `cd` into the base dir for the env you want to work on
  - `cd terraform-<service>/env-development/`
- `./init.sh` # to initialize your environment
- `terraform get` # to load your modules
- `terraform plan -var-file=development.tfvars` # manage all the things!
