=======
scality
=======

Formulas to setup and configure Scality software components.

.. note::

    For more details, see `Using Salt to Install Scality Components
    <http://docs.scality.com/display/DOCS/Start>`_.

Available States
================

.. contents::
    :local:

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

``scality.sindexd``
-------------------

Installs the scality-sindexd package and its dependencies.

``scality.sproxyd``
-------------------

Installs the scality-sproxyd package and its dependencies.

``scality.srebuildd``
---------------------

Installs the scality-srebuildd package and its dependencies.

``scality.repo``
----------------

Configure the package manager to use the Scality repository with the selected
variant. This state requires that you set your login and password in the
pillar.

``scality.req``
---------------

Installs and configures packages and system parameters required by all Scality
components. These requirements are defined in the documentation wiki:

- Server Swapiness

- Incompatible Software

- Network Time Protocol


