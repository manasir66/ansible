# Ansible Role for Passbolt
Explained below are the steps requied to run the playbook, along with my thoughtprocess, decision making and challenges faced along the way.

## Understanding Requirements
I broke down the requirements as follows.

### Main Requirements: 
- Install Passbolt 
- Option to setup Passbolt with SSL if required 

### Sub Requiements 
- Ubuntu 20.04 to be used at all intances throughout the experiment 
- Vagrant is required for local testing 
- Install Dependencies 

## Running the playbooks

### Local testing using Vagrant
1. `cd vagrant && Vagrant up` : This step assumes Vagrant is installed and configured in your local developer environment 

2. `ansible-playbook -i inventory/hosts playbook.yaml --limit vagrant`
The `limit` command will narrow down the group under the hosts inventroy file. ex: if you want to deploy to all `dev` servers you can specify `--limit dev`

3. If `SSL` is required, adjust the parameters accordingly and change `passboltDeploy` to `passboltDeploySSL` instead. This assumes there is a valid dns record pointing to the IP hosting the server

### In the cloud
1. Directly run ansible-playbook -i inventory/hosts playbook.yaml --limit `cloud_group_name`

## Decions Made
After carefully reading the passbolt documentation, the least time consuming approach ( that has production grade validity ) is installing via docker. This required the following steps 
1. update the os modules
2. install `docker` and `docker compose`
3. setup the correct docker-compose yaml file in the templates and run it
4. setup the backup cron job to exec into the containers as highlighed in the documentation

Decision Reason : 
1. to avoid unnecessary dependencies installed on the machine. Often times there are `dep clashes` that can result in some module causing the whole installation to be stalled.
2. Any potential issues can be easily cleaned up using the containers
3. Accessible logs in one place for troubelshooting 
   1. Ex scenario: 1  first deployed using the default compose file which resulted in passbolt not showing data, this was due to the `APP_FULL_BASE_URL: https://passbolt.local` and the dns config was not present

## Challenges Faced

1. Vagrant : Vagrnat setup was failing via VB provider on m1 mac due to arch type, resolved by switcing to and x64 arch machine for local dev
2. Selecting the right best practise : there are many standars that can be adopted for ansible. I followed the role based approach.
3. Finding ubuntu 20.04 in AWS was a challange, baseOS is deprecated, however, it was available in Azure. (AWS has one variant with sql pre installed )
4. Lack of cloud sotre for secure backup although backup was setup ( I have setup a generic template )

## Recommendations & Suggestions

Although I was unabled to integrate, here are some of my suggestions.

1. Load balancer should be in a separate server, while passbolt can be across 3 servers for High Availability 
2. In HA mode, db's can be separated out from the main compute engine (db store)
3. Upgrading from ubuntu 20.04 to a new release for LTS ( long term support )

## Resources
List of resources

[resources : provided]
- https://help.passbolt.com/hosting/install/ce/start
- https://docs.ansible.com/

[resources : used]
- https://github.com/JamesTurland/JimsGarage/tree/main/Ansible
- debugging : https://stackoverflow.com/ , https://www.perplexity.ai/ and https://www.phind.com/
- https://technotim.live/posts/ansible-automation/
- https://github.com/solairen/passbolt
  