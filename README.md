Ansible Deployment for HARNESS demo on grid5000
===============================================

The purpose of this ansible deployment is to configure and set up the HARNESS
system on grid5000 for testing, experimentation, and demonstration. It is not
intended for production use.

Preparation
-----------

These steps need to be completed in order to successfully deploy the HARNESS
demonstrator platform on grid5000. This setup procedure should only need to be
done once on the frontend (login host from which you can submit oar jobs) for
each grid5000 site that you intend to use. 

### Step 1: configure environment variables

On Grid5000 nodes do not have direct access to the outside network, so it is
necessary to set the http_proxy and https_proxy environment variables to the
value "http://proxy:3128". Also, you will need to install ansible to your local 
account, so ~/.local/bin needs to be in the path. The easiest thing is to do is 
to edit your .bashrc file on the front end node to include the following lines:

    export http_proxy=http://proxy:3128
    export https_proxy=$http_proxy
    export PATH=$HOME/.local/bin:$PATH

### Step 2: install ansible

Assuming that you have completed step 1 correctly and reloaded your environment
(source ~/.bashrc or logout and then log in again), you should be able to
install ansible to your home directory with the following command:

    easy_install --user ansible

After this step is completed make sure that you can run ansible:

    ansible --help

### Step 3: configure ssh

The secure shell has a number of features that are important for security in
a real-world distributed environment, but that unfortunately make things a bit
difficult on grid5000. To make life easier we need to disable them.

The first thing we need to do is to disable host-key checking. Since each node
will have it's operating system refreshed every time the operating system is
deployed, the host keys will change every time. This means that the feature
does not add to security, and will cause problems for ansible. To disable this
feature, edit ~/.ssh/config and make sure the following settings are in place
(they may already be present):

    Host *
      StrictHostKeyChecking no
      HashKnownHosts no

The second thing we need to do is make sure that you can ssh from the frontend 
to the nodes granted to you by oar without entering a password. To do this, 
simply create a password-less ssh public key on the frontend with the following 
command:

    ssh-keygen -t rsa -N ''

To make sure that the key will be propagated to your nodes run:

    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

It is important that this insecure key *only* be used on grid5000, for the
purpose of accessing temporarily assigned nodes from the frontend.

### Step 4: clone the ansible-deployment-harness-demo-g5k repository

As the gitlab.harness-project.eu site is not accessible through the g5k proxy,
use the bitbucket URL to clone the project:

    git clone https://bitbucket.org/marklee77/ansible-deployment-harness-demo-g5k.git
    
To get the ansible roles used by this deployment, cd to the
ansible-deployment-harness-demo-g5k directory and run the following command:

    ansible-playbook -i inventories/demo.ini provisioning/getreqs.yml

Note that this step results in the current version of the deployment being
installed to your account. To update your deployment it may be necessary to
"git pull" and then re-run the above-listed ansible-playbook command to update
the roles.

Deployment
----------

Deploying the HARNESS platform is a multi-step process requiring first 
requesting nodes from the job scheduler, then installing the base operating 
system on these nodes, preparing the nodes, and finally running the ansible 
deployment script.

### Step 1: request some nodes for the deployment from the scheduler

The OAR scheduler is complicated, and the oarsub command can take a lot of
options depending on exactly what you want. In it's most basic form you will need to run something like:

    oarsub -t deploy -I -l /cluster=1/nodes=3,walltime=4:00:00



Author Information
------------------

http://stillwell.me

Todo
----

- roles should have distinct install and configuration phases only, with 
  configuration occurring at startup in docker using a launch script, all
  long-running processes should be managed by supervisor

- all test/demo variables should be moved out of defaults/ and group_vars/ and
  and set at the top of test.yml

- every role should have a test and be set up for ci in travis...

- consistent use of admin token vs admin login user and password for keystone...
