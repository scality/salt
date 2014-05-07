
{% from "scality/map.jinja" import scality with context %}

{%- set prod_ip = salt['network.ip_addrs'](interface=scality.prod_iface)[0] %}

extend:
  scality-sagentd:
    debconf.set:
      - name: scality-sagentd
      - data:
          scality-sagentd/supervisor-ip: {'type': 'string', 'value': {{ scality.supervisor_ip }}}
      - require:
        - pkg: debconf-utils
    pkg:
      - require:
        - debconf: scality-sagentd
