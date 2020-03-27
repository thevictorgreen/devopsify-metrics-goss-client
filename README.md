gossclient
=========

The gossclient Ansible Role installs all client utilites to allow automated goss tests
to be ingested into an AWS Kinesis Data Stream

Requirements
------------

AWS IAM role allowing access to AWS Kinesis is requried and should be attached to each EC2
Instance where this Ansilbe Role will be applied.

Role Variables
--------------

No role varialbes in use.

Dependencies
------------

No further role dependencies requried

Example Playbook
----------------

    - hosts: servers
      roles:
         - role: gossclient

License
-------

BSD

Author Information
------------------

Victor Green.
