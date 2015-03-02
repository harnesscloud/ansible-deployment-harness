Ansible Deployment for HARNESS demo on grid5000
===============================================

The purpose of this ansible deployment is to configure and set up the HARNESS
system on grid5000 for testing, experimentation, and demonstration. It is not
intended for production use.

Preparation
-----------


https://bitbucket.org/marklee77/ansible-deployment-harness-demo-g5k.git

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
