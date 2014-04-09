
include:
  - scality.node
  - scality.sagentd.registered

{% from "scality/map.jinja" import scality with context %}
{% from "scality/node/helpers.sls" import for_all_nodes with context %}

{%- set prod_ip = salt['network.ip_addrs'](interface=scality.prod_iface)[0] %}

{% call(node) for_all_nodes() %}

# make sure the node is listening before we try to add it
check-{{ node.name }}-listening:
  scality_node.listening:
    - address: {{ prod_ip }}
    - port: {{ node.mgmt_port }}
    - require:
      - service: scality-node
      - scality_server: register-{{grains['id']}}

# add the node to its ring
add-{{ node.name }}:
  scality_node.added:
    - name: {{ node.name }}
    - ring: {{ node.ring }}
    - supervisor: {{ scality.supervisor_ip }} 
    - require:
      - scality_node: check-{{ node.name }}-listening

{% endcall %}

all-nodes-available:
  scality_server.available:
    - require:
{%- call(node) for_all_nodes() %}
      - scality_node: add-{{ node.name }}
{%- endcall %}
    - watch:
      - service: scality-node
