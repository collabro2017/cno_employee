New deployment steps - Part 1
===

## Base dev environment and aws-cli setup

1. Setup an aws instance (Amazon linux AMI).  This instance will be used to clone the github repository to begin a new deployment and also for development testing. -- More to be added about aws ssh keys and pscp if using a windows box for development.

  * Prerequisites before continuing - Ability to SSH into the new created AWS instance with ssh(linux) or PuTTY(windows), ability to copy and install ssh key pairs to newly created AWS instances using scp(linux) or pscp(windows)

  * For more information on using pscp to transfer keys in a local windows environment go [here](Documentation/pscp_setup.md)

  * For more information on using ssh with PuTTY go [here](Documentation/PuTTY_AWS_keys.md)

  * For more information on installing a private key on an ec2 instance go [here](Documentation/installing_private_key_ec2.md)

2. SSH into the newly created aws instance and install rvm (ruby version manager).
    
  * Make sure port 11371 is open in the security group, associated with this instance, for gpg key server

  `$ gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3`

  `$ \curl -sSL https://get.rvm.io | bash -s stable --ruby`

3. Install Ruby version 2.1.2

  `$ rvm install 2.1.2`

4. Install git if needed.

  `$ sudo yum install git-all`

5. Create and add ssh key to github repository.  Further instructions can be found here: https://help.github.com/articles/generating-an-ssh-key/

6. Clone the repository.

  `$ git clone git@github.com:<repository account>/<repository name>`

7.  Install bundler (ruby package manager)

  `$ gem install bundler`

8. Set aws environment variables for aws-sdk
  ```bash
$ export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
$ export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
$ export AWS_DEFAULT_REGION=us-west-2
```

  * This script will fail if there are already security groups, vpc, and subnets created that match the id's in the config files /CnO/DevOps/aws_setup/component_creation/config/

  * Make sure all the AMI's are updated in the configs

  * In vpc_nat.yml set the name, security_group_name and others if needed before running init_scenario_2.rb

  * In scenario_2.yml set  the vpc_name, cidr_block, gateway_name, route_table_name, main_route_table_name, subnets_array (private and public) if needed before running init_scenario_2.rb

1. Update the config files in Cno/DevOps/aws_setup/component_creation/config to match the the aws region to deploy to, along with the key name in IAM that is going to be used in the deployment.  Also check the aws_ec2.rb file in CnO/DevOps/aws_setup/component_creation/lib/common and verify the @connection variable is set to the region the application will be deployed to.

2.  Go to Cno/DevOps/aws_setup/component_creation/scripts and run

  `$ bundle install`

  `$ ruby init_scenario_2.rb`

  This script will build the vpc nat along with the security groups on the specified region.
  More information on AWS VPC NAT scenario 2 can be found here http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Scenario2.html

3. Open cno_env.yml and add the public-subnet id to the frontend group and the private-subnet id to the backend group.
The subnet ID can be found in the VPC Dashboard. https://console.aws.amazon.com/vpc/

4.  While cno_env.yml is open add the FrontEndSG and BackEndSG ID's to the corresponding groups.  These can also be found in the VPC Dashboard under Security/Security Groups menu.

5.  Run the next script to launch all the AWS instances in CnO/DevOps/aws_setup/component_creation/scripts/

  `$ ruby init_cno_env.rb`

