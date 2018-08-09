Launch Strategy
===
### 1. Setup Amazon VPC and AWS Scenario 2

Pre-requisites:

* Make sure you don't repeat used values for the following attributes updates.
* Update names and references of security groups in _.rules_ files inside folder
  _/CnO/DevOps/aws_setup/component_creation/config/_.
* Inside the same folder mentioned before, update the following attributes in
  file _vpc_nat.yml_: name, security_group_name, and others if necessary.
* Inside the same folder mentioned before, update the following attributes in
  file _scenario_2.yml_: vpc_name, cidr_block, gateway_name, route_table_name,
  main_route_table_name, subnets_array (private and public).
* Have all the AMIs updated, if not re-create them.

Enter to folder /Cno/DevOps/aws_setup/component_creation/scripts/ and run the
script __init_scenario_2.rb__ with the next command: `$ ruby init_scenario_2.rb`

### 2. Launch Instances

Update the file _cno_env.yml_ inside folder
/Cno/DevOps/aws_setup/component_creation/config/ with the corresponding
configuration for each instance that compose the CnO environment.

Enter to folder /Cno/DevOps/aws_setup/component_creation/scripts/ and run the
script __init_cno_env.rb__ with the next command: `$ ruby init_cno_env.rb`

If you want to launch each instance individually, then use the script named
__init_instance.rb__ and set the flag indicating the instance you want to launch,
for help information set the flag _-h_ in the following command:
`$ ruby init_instance.rb -h`

NOTE: if you want to launch an instance (i.e. ftp server) with many extra EBS
volumes but with different sizes, you just have to run the launch script several
times, the first time give initial sizes and the corresponding count, the next
time the script is going to ask if you want to attach the new volumes to the
existent instance, then write 'yes'.

### 3. Run mounting scripts of extra volumes

Connect to Central DS and each Node DS through the NAT Instance, then inside
home folder of ec2-user there is a subfolder named _Scripts_ that contains the
file _mount_ebs_script.sh_ used to create, mount and set related configuration
to the RAIDs for each instance, run that script after you have all the needed
volumes correctly attached.

### 4. Launch Deployer

Launch or start the Deployer instance using the Base AMI, but do not include
this instance inside the Domain you want to deploy because the Deployer is
independent from Domains.

After the instance is _:running_ execute the _main deployment_, for more
information check Mina's documentation at
/CnO/DevOps/mina/documentation/README.md.

When you finish using it, then stop it but do not terminate it unless is
completely necessary.

### 5. Hosts Propagation

In the _current_ folder inside Deployer instance there is a folder named
_hosts_propagation_ that contains the script, classes, and configuration files
needed to propagate hostnames and private IPs through an specific Domain of
instances.

Enter the folder _Mina/current/hosts_propagation/scripts/_ and execute the file
__init_host_table_propagation.rb__ with the following command:

`$ bundle exec ruby init_host_table_propagation -d <DOMAIN_NAME> --privately`

### 6. Configure FTP server

Connect to FTP server through ssh and manually set the MasqueradeAddress
attribute (with the public IP) in file _/etc/proftpd.conf_, because the instance
is behind a NAT.

For more information check _/CnO/DevOps/packer/documentation/ftp_server.md_.

### 7. Deployment

To deploy to each instance (rails_app, central, nodes) refer to Mina's
documentation at _/CnO/DevOps/mina/documentation/README.md_.

### 8. Install extra modules

[TO-DO]: steps to install customers module and new ones using Mina.

### 9. Datafile Processing

Refer to DFP documentation at the corresponding Github repository.

### 10. Configure the elastic IP for RailsApp

Configure an AWS elastic IP only if it is necessary.

### 11. Test and Cleanup

After all the instances are deployed and running, test the CnO application
running counts, orders, dedupes, breakdowns, exclude, suppress, and other
functionality. Then stop the deployer instance and clean up any old environment.

