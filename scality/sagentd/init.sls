include:
  - scality.req
  - scality.repo
  - .{{ grains['os_family'] }}

{% from "scality/map.jinja" import scality with context %}

scality-sagentd:
  pkg:
{%- if pillar['scality'] is defined and pillar['scality']['version'] is defined %}
    - version: {{ salt['pillar.get']('scality:version') }}
    - installed
{%- else %}
    - latest
{%- endif %}
    - require:
      - pkgrepo: scality-repository
  file:
    - exists
    - name: /etc/sagentd.yaml
    - require:
      - pkg: scality-sagentd
  service:
    - running
    - enable: True
    - require:
      - service: ntpd
    - watch:
      - pkg: scality-sagentd
      - file: /etc/sagentd.yaml

