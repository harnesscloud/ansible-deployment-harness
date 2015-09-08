Ansible Deployment for HARNESS
==============================

[![Build Status](https://buildbot.harness-project.eu/png?builder=ansible-deployment-harness-runtests)](https://buildbot.harness-project.eu/builders/ansible-deployment-harness-runtests) 

The purpose of this ansible deployment is to configure and set up the HARNESS
system on various target platforms, including vagrant-provisioned virtual
machines and Grid'5000 for testing, experimentation, and demonstration.

In order to try out HARNESS within a virtual machine, simply check out this 
project, cd into the root directory of the project, and run the command 
"vagrant up".

More detailed instructions are provided for deploying HARNESS on to Grid'5000.
Portions of this document are based on an existing howto for deploying vanilla
OpenStack Grizzly (ref:
https://www.Grid'5000.fr/mediawiki/index.php/OpenStack_Grizzly).

You should make sure that you have reviewed the Grid'5000 getting started guide
(ref: https://www.Grid'5000.fr/mediawiki/index.php/Getting_Started) before
proceeding if you have not previously worked with Grid'5000.

Preparation
-----------

These steps need to be completed in order to successfully deploy the HARNESS
demonstrator platform on Grid'5000. This setup procedure should only need to be
done once on the frontend (login host from which you can submit oar jobs) for
each Grid'5000 site that you intend to use. 

### Step 1: configure environment variables

On Grid'5000 nodes do not have direct access to the outside network, so it is
necessary to set the http_proxy and https_proxy environment variables to the
value "http://proxy:3128". Also, you will need to install ansible to your local
account, so ~/.local/bin needs to be in the path. The easiest thing is to do is
to edit your .profile on the frontend to include the following lines:

    export http_proxy=http://proxy:3128
    export https_proxy=$http_proxy
    export PATH=$HOME/.local/bin:$PATH

### Step 2: install ansible

Assuming that you have completed step 1 correctly and reloaded your environment
(source ~/.profile or logout and then log in again), you should be able to
install ansible to your home directory with the following command:

    easy_install --user ansible netaddr

After this step is completed make sure that you can run ansible:

    ansible --help

### Step 3: configure ssh

The secure shell has a number of features that are important for security in
a real-world distributed environment, but that unfortunately make things a bit
difficult on Grid'5000. To make life easier we need to disable them.

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

It is important that this insecure key *only* be used on Grid'5000, for the
purpose of accessing temporarily assigned nodes from the frontend.

This recommendation for managing ssh keys is consistent with the official
Grid'5000 documentation (ref:
https://www.Grid'5000.fr/mediawiki/index.php/SSH#SSH_key_passphrase).

### Step 4: clone the ansible-deployment-harness-demo-g5k repository

As the gitlab.harness-project.eu site is not accessible through the g5k proxy,
use the github URL to clone the project:

    git clone https://github.com/harnesscloud/ansible-deployment-harness.git
    
To get the ansible roles used by this deployment, cd to the
ansible-deployment-harness-demo-g5k directory and run the following command:

    ansible-playbook -i inventories/local.ini getreqs.yml

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
deployment playbook.

### Step 0 (optional): start gnu screen to protect your session

These instructions are oriented toward an interactive session, so if you follow
the instructions in the next section and then need to disconnect for some
reason (e.g., network outage, or you need to shut down your laptop) then you
will lose your session, the nodes will be unreserved, and you will have to
start over again from step 1. To protect against this, run the "screen" command
to protect your session. If you are ever disconnected then just log back in to
your Grid'5000 site and run "screen -R" to reconnect. You should see that
everything has continued running as though you never left. If you want to to
disconnect without terminating your session or closing your terminal
application, then just type "CTRL-a d" (control+a and then d) to disconnect,
then exit or logout as you would normally. 

### Step 1: request nodes for the deployment from the scheduler

The OAR scheduler is complicated, and the oarsub command can take a lot of
options depending on exactly what you want (ref:
https://www.Grid'5000.fr/mediawiki/index.php/Advanced_OAR). In it's most basic
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
with a /22 subnet, for 4 hours. It is very important to follow the Grid'5000
user guidelines (ref:
https://www.Grid'5000.fr/mediawiki/index.php/Grid'5000:UserCharter) for
acceptable usage when deciding on a number of nodes and for how long you want
the reservation.

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
following command:

    ansible-playbook -i inventories/g5k.sh deploy.yml

Using HARNESS on Grid'5000 
-------------------------

As the environment within the Grid'5000 clusters is fairly insecure, some effort
has been put into isolating Grid'5000 from the wider internet. This means, for
example, that nodes cannot directly access or be accessed from outside.
Obviously, it should be possible to ssh to the root account of any node from
the frontend machine. 

If, while on a node, you need to download something from the internet, do not
forget that you may need to set the http_proxy or https_proxy environment
variables to do so, and that even then the most straightforward thing to do
might be to use scp to copy your files to the frontend and then again to copy
from the frontend to the nodes. *It is important to not set this variable by
default on the controller as it can break some of the openstack command-line
clients*. The affected commands will fail with a 503 error, so if you see this
error, be sure to check the http_proxy and HTTP_PROXY environment variables.

You can also use easy_install or pip to install the command lines to your home 
directory on the frontend machine, download the admin or demo .openrc files and 
run commands from the front end. Don't forget to disable the http_proxy 
environment variable if you need to use the neutron command.

If you need to interact with your VMs or services from outside of Grid'5000 then
you will first need to set up your local ssh configuration to use the
ProxyCommand directive as described here on the G5K wiki (ref:
https://www.Grid'5000.fr/mediawiki/index.php/SSH).

Once this is set up correctly so that you can access a site by typing "ssh
site.g5k" from the command line, you will be able to set up SOCKS proxy tunnels
using the command "ssh -D PORT site.g5k". For example:

    ssh -D 9999 rennes.g5k

Once this is done you can go into your the network settings for your web
browser and configure it to use a SOCKS proxy. In firefox for this example you
would go to "Preferences", then "Advanced", then "Network" and click the
"Settings" button in the Connection section. Then fill out SOCKS host as
"localhost" and port as "9999". It is important to note that all network
traffic for the web browser will now be sent through Grid'5000, and thus you
should put any servers that you want to be able to connect to that are located
outside of Grid'5000 in the "No proxy for:" box. In particular, it is
recommended that you add ".harness-project.eu" to this list.

After the SOCKS proxy is configured in your browser you should be able to
access the CRS and ConPaaS urls that are displayed when the playbook completes
successfully. The default ConPaaS user is "test" and the default password is
"password". Please change these values for any production deployment.

Author Information
------------------

Mark Stillwell <mark@stillwell.me>
http://stillwell.me


