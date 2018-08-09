New deployment steps - Phase 2
--------------------------

### Setting up tmux

1. SSH into the newly created VPC-NAT instance.

2. Install tmux (terminal multiplexer) for easy access to all the backend instances. Go [here](Documentation/tmux_quick_guide.md) for a quick reference of tmux commands and shortcuts.

  `$ sudo yum install tmux`

3. Once tmux is installed add the private from the aws key-pair that was used to spawn all the instances. This will need to be done for each tmux window created.  For more information on install the private key go [here](Documentation/installing_private_key_ec2.md)

### Mounting raid devices in central datastore and node datastores

  * As of now the shell script that needs to be run to setup the RAID drives in the image doesn't not match the device names in AWS and this has to be changed for each node and central datastore (PITA and needs to be fixed)

  1.  On the central datastore and each node change the first to commands in /home/ec2-user/scripts/mount_ebs_script.sh to:

  ```
  sudo sh -c "yes | sudo mdadm --create /dev/md/$HOSTNAME:0 --chunk=256 --level=0 --raid-devices=8 /dev/xvdb[a-h] " &&
  sudo sh -c "echo 'DEVICE' /dev/xvdb[a-h] >> /etc/mdadm.conf" &&
  ```
### Mina deployment from dev instance to deployer instance

setup a new 'deployer' instance if one isn't already created, use the deployer AMI.
add dev instance to SG
add the first level main deployment steps here
issue tracker about the host propagation table steps
