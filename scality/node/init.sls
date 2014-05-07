include:
  - scality.req
  - scality.req.hosts
  - scality.python
  - .{{ grains['os_family'] }}
  - .log

{% from "scality/map.jinja" import scality with context %}

scality-node-init-conf:
    file:
      - managed
      - name: {{ scality.init_conf_dir }}/scality-node
      - source : salt://scality/node/scality-node

scality-node:
  pkg:
{%- if pillar['scality'] is defined and pillar['scality']['version'] is defined %}
    - version: {{ salt['pillar.get']('scality:version') }}
    - installed
{%- else %}
    - latest
{%- endif %}
    - require:
      - pkgrepo: scality-repository
      - pkg: scality-sagentd
  service:
    - running
    - enable: true
    - sig: bizstorenode
    - watch:
      - pkg: scality-node
      - file: scality-node-init-conf
