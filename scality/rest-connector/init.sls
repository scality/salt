include:
  - scality.req
  - scality.ringsh
  - .{{ grains['os_family'] }}

scality-rest-connector:
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
    - require:
      - pkg: scality-rest-connector
    - watch:
      - pkg: scality-rest-connector
