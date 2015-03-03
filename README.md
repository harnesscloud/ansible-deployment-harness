Ansible Deployment for HARNESS demo on grid5000
===============================================

The purpose of this ansible deployment is to configure and set up the HARNESS
system on grid5000 for testing, experimentation, and demonstration. It is not
intended for production use.

Portions of this document are based on an existing howto for deploying vanilla
OpenStack Grizzly:

    https://www.grid5000.fr/mediawiki/index.php/OpenStack_Grizzly

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
to edit your .profile on the frontend to include the following lines:

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

The file inventories/g5k.sh is a shell script that will read the OAR_NODE_FILE
created by oar to describe your reservation and generate an inventory usable by
ansible. It needs to be executable, but git does not manage file permissions,
so be sure to set the executable bit on this file:

    chmod +x inventories/g5k.sh

Deployment
----------

Deploying the HARNESS platform is a multi-step process requiring first 
requesting nodes from the job scheduler, then installing the base operating 
system on these nodes, preparing the nodes, and finally running the ansible 
deployment script.

### Step 1: request some nodes for the deployment from the scheduler

The OAR scheduler is complicated, and the oarsub command can take a lot of
options depending on exactly what you want (see:
https://www.grid5000.fr/mediawiki/index.php/Advanced_OAR). In it's most basic
form you will need to run something like:

    oarsub -t deploy -I -l slash_22=1+cluster=1/nodes=3,walltime=4:00:00

In the above command "-t deploy" is required for a job that will involve
deployment; that is, reinstalling the operating systems of the provisioned
nodes. The option, "-I" says that the job is *interactive*, meaning that once
the nodes are granted a new shell will be opened in the current session, with
environment variables set to tell you what nodes you have access to and other
required information. *If you exit out of this shell then you will lose the
reservation*. Thus, all subsequent commands should be run from the same
session/login as the oarsub command, and you should not exit this session until
you are done with your reservation. The final option gives some information
about what you want to reserve, in this case 3 nodes, all on the same cluster,
with a /22 subnet, for 4 hours. It is very important to follow the grid5000
user guidelines for acceptable usage when deciding on a number of nodes and how
long you want the reservation for:

    https://www.grid5000.fr/mediawiki/index.php/Grid5000:UserCharter

### Step 2: install ubuntu 14 on to your reserved nodes

Once you have a reservation, from the same session where you ran the oarsub
command, run kadeploy to put a fresh install of ubuntu trusty on to your
reserved nodes:

    kadeploy3 -f $OAR_NODE_FILE -e ubuntu-x64-1404 -k

The "-k" option on the end tells kadeploy to copy the contents of
authorized_keys from your frontend account to the root account on each of your
nodes.

### Step 3: use ansible to deploy the HARNESS platform

Change to the ansible-deployment-harness-demo-g5k directory and run the
following two commands:

    ansible-playbook -i inventories/g5k.ini provisioning/deploy.yml

Using HARNESS on Grid5000
-------------------------

As the environment within the grid5000 clusters is fairly insecure, a fair
amount of effort has been put into isolating grid5000 from the wider internet.
This means, for example, that nodes cannot directly access or be accessed from 
outside. Obviously, it should be possible to ssh to the root account of any node 
from the frontend machine. In order to access web services running on the nodes 
you may need to tunnel traffic over ssh, for example by using "ssh -D".

For any node running a web server; a service running on port 80 can be accessed
through a URL that follows this scheme:

    https://mynode.mysite.proxy-http.grid5000.fr/

Services running with SSL on port 443 can be accessed more directly:

    https://mynode.mysite.grid5000.fr/

If, while on a node, you need to download something from the internet, do not
forget that you may need to set the http_proxy or https_proxy environment
variables to do so, and that even then the most straightforward thing to do
might be to use scp to copy your files to the frontend and then again to copy
from the frontend to the nodes.

Author Information
------------------

http://stillwell.me

Todo
----

- kavlan network isolation?
- kernel updates on nodes?
