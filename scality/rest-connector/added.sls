
include:
  - scality.rest-connector
  - scality.sagentd.registered

{% from "scality/map.jinja" import scality with context %}

{% set prod_ip = salt['network.ip_addrs'](interface=scality.prod_iface)[0] %}
{% set data_ring = scality.rings.split(',')[0] %}

check-connector-listening:
  scality_rest_connector.listening:
    - address: {{ prod_ip }}
    - require:
      - scality_server: register-{{ grains['id'] }}
      - service: scality-rest-connector

add-rest-connector:
  scality_rest_connector.added:
    - name: {{ scality.ctor_name_prefix }}1
    - ring: {{ data_ring }}
    - require:
      - scality_rest_connector: check-connector-listening
