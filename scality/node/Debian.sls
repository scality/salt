
include:
  - scality.repo
  - scality.sagentd

{% from "scality/map.jinja" import scality with context %}

{%- set prod_ip = salt['network.ip_addrs'](interface=scality.prod_iface)[0] %}

extend:
  scality-node:
    debconf.set:
      - name: scality-node
      - data:
          scality-node/node-ip: {'type': 'string', 'value': {{ prod_ip }}}
          scality-node/processes-count: {'type': 'string', 'value': {{ scality.nb_nodes }}}
          scality-node/accept-license: {'type': 'boolean', 'value': True}
          scality-node/mount-prefix: {'type': 'string', 'value': {{ scality.mount_prefix }}}
          scality-node/biziod-count: {'type': 'string', 'value': {{ scality.nb_disks }}}
          scality-node/use-ssl: {'type': 'boolean', 'value': False}
          scality-node/name-prefix: {'type': 'string', 'value': {{ scality.name_prefix }}}
          scality-node/keep-config: {'type': 'boolean', 'value': True}
          scality-node/tier2-enabled: {'type': 'boolean', 'value': False}
          scality-node/warning-mount: {'type': 'boolean', 'value': True}
          scality-node/setup-sagentd: {'type': 'boolean', 'value': True}
          scality-node/restart: {'type': 'boolean', 'value': False}
      - require:
        - pkg: debconf-utils
    pkg:
      - require:
        - debconf: scality-node

  