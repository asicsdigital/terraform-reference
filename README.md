Terraform Control repo built following the pattern as outlined by [Charity Majors](https://charity.wtf/2016/03/30/terraform-vpc-and-why-you-want-a-tfstate-file-per-env/)

TLDR, but really, go read the post, it's way better then what I'm going to write here..

### Terraform Version

The Current production [terraform version](https://github.com/FitnessKeeper/terraform-runkeeper#terraform-version) can be found here
### To create a new repo using the terraform-reference repo.

- Clone the repo `git clone https://github.com/FitnessKeeper/terraform-reference`
- Edit .env in the root of the repo, in particular make sure you add a TF_PROJECT_NAME
  - When creating a `spike` make sure you update TF_SPINE in env if something other then `rk` is needed, at the time of this writing `rk` and `asics` are valid spines.
  - Also when creating ASICS `spikes` update to `TF_LOCK_TABLE=asics-services-terraformStateLock` 
- Initialize variables.tf, this only needs to be done once, when the repo is created run `./init-variables.tf.sh`
-  Remove the old origin `git remote rm origin`
-  Add your new repo `git remote add origin https://github.com/FitnessKeeper/terraform-reference.git`
- Commit your changes
- `git push -u origin master`
- Edit variables.tf to reflect your new service



### To use an environment in the control repo
- `cd` into the base dir for the env you want to work on
  - `cd terraform-<service>/env-development/`
- `./init.sh` # to initialize your environment
- `terraform get` # to load your modules
- `terraform plan -var-file=development.tfvars` # manage all the things!

### Design pattern

We are trying to follow a pattern where we have an infrastructure repo with 3 tiers - dev, stage, and production, known as FitnessKeeper/terraform-runkeeper. We will use that control repo to build VPC, ECS Clusters, DNS Zones, and other resources that can be presented as a platform for use by services.  

  Services, will be created using atomic control repos, based off this skel, and have distinct state files for each of the tiers. In this way, we can make changes to the state of a service living atop our infrastructure, without having to push stage changes to the underlying resources.
