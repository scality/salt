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

``scality.sindexd.apache``
-------------------

Installs and configures sindexd behind an apache 2 frontend

``scality.sindexd.lighttpd``
-------------------

Installs and configures sindexd behind a lighttpd frontend

``scality.sproxyd.apache``
-------------------

Installs and configures sproxyd behind an apache 2 frontend

``scality.sproxyd.lighttpd``
-------------------

Installs and configures sproxyd behind a lighttpd frontend

``scality.srebuildd.apache``
-------------------

Installs and configures srebuildd behind an apache 2 frontend

``scality.srebuildd.lighttpd``
-------------------

Installs and configures srebuildd behind a lighttpd frontend

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


