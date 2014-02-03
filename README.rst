=======
scality
=======

Formula to setup and configure Scality software components.

.. note::

    For more details, see `Using Salt to Install Scality Components
    <http://docs.scality.com/display/DOCS/Start>`_.

Available States
================

This formula defines two kinds of states:

- the main states are those that needs to be referenced in the top file to setup
  components such as store servers or connectors on minions.
- the helper states as their name implies provide configuration that is common to several main states
  and are brought in using Salt include directives. They should rarely need to be referenced directly but
  some of them may require parameters to be set in the pillar.

.. contents::
    :local:

Main States
+++++++++++

``scality.supervisor``
----------------------

Installs the scality-supervisor package and its dependencies.

``scality.ringsh``
------------------

Installs and configures the scality-ringsh package.

``scality.node``
----------------

Installs the scality-node package and its dependencies.

``scality.rest-connector``
--------------------------

Installs the scality-rest-connector package and its dependencies.

``scality.sindexd.apache``
--------------------------

Installs and configures sindexd behind an apache 2 frontend

``scality.sindexd.lighttpd``
----------------------------

Installs and configures sindexd behind a lighttpd frontend

``scality.sproxyd.apache``
--------------------------

Installs and configures sproxyd behind an apache 2 frontend

``scality.sproxyd.lighttpd``
----------------------------

Installs and configures sproxyd behind a lighttpd frontend

``scality.srebuildd.apache``
----------------------------

Installs and configures srebuildd behind an apache 2 frontend

``scality.srebuildd.lighttpd``
------------------------------

Installs and configures srebuildd behind a lighttpd frontend

Helper States
+++++++++++++

``scality.repo``
----------------

Configure the package manager to use a repository to install Scality packages. This state requires a few
parameters to be set in the pillar.

To use a private repository, set the following parameters:

.. code-block:: yaml

  scality:
    repository:
      variant: stable
      private: http://repo.example.com/

On RedHat/CentOS, this instructs the package manager to look for packages under::

   `http://repo.example.com/stable/centos/$releasever/$basearch/`

On Ubuntu, this instructs the package manager to look for packages under::

   `http://repo.example.com/stable/ubuntu/`

To use Scality's repository, set the following parameters:

.. code-block:: yaml

  scality:
    repository:
      variant: stable
      login: your_username_on_packages.scality.com
      password: your_password_on_packages.scality.com


``scality.req``
---------------

Installs and configures packages and system parameters required by all Scality
components. These requirements are documented as best practices in the `documentation 
wiki <http://docs.scality.com/display/R42/Requirements+and+Recommendations+for+Installation>`_:

- Server Swapiness

- Incompatible Software

- Network Time Protocol


