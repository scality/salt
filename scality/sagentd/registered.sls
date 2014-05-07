
include:
  - scality.python
  - scality.sagentd

{% from "scality/map.jinja" import scality with context %}

# register sagentd with the supervisor
register-{{grains['id']}}:
  scality_server:
    - registered
    - name: {{ grains['id'] }}
    - address: {{ salt['network.ip_addrs'](interface=scality.prod_iface)[0] }}
    - require:
      - pkg: python-scalitycs
      - service: scality-sagentd
