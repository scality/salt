
include:
  - scality.repo
  - scality.sagentd

{% from "scality/map.jinja" import scality with context %}

{%- set prod_ip = salt['network.ip_addrs'](interface=scality.prod_iface)[0] %}

extend:
  scality-rest-connector:
    debconf.set:
      - name: scality-rest-connector
      - data:
          scality-rest-connector/supervisor-ip: {'type': 'string', 'value': {{ scality.supervisor_ip }}}
          scality-rest-connector/disable-default-apache-ports: {'type': 'boolean', 'value': False}
          scality-rest-connector/use-ssl: {'type': 'boolean', 'value': False}
          scality-rest-connector/connector-ip: {'type': 'string', 'value': {{prod_ip}}}
          scality-rest-connector/accept-license: {'type': 'boolean', 'value': True}
          scality-rest-connector/setup-sagentd: {'type': 'boolean', 'value': True}
          scality-rest-connector/keep-config: {'type': 'boolean', 'value': True}
          scality-rest-connector/name-prefix: {'type': 'string', 'value': {{scality.ctor_name_prefix}} }
          scality-rest-connector/restart: {'type': 'boolean', 'value': False}
      - require:
        - pkg: debconf-utils
    pkg:
      - require:
        - debconf: scality-rest-connector
