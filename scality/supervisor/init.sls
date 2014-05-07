
{% from "scality/map.jinja" import scality with context %}

include:
  - scality.req
  - scality.python
  - .{{ grains['os_family'] }}

{%- set log_base = salt['pillar.get']('scality:log:base_dir', '/var/log') %}

scality-supervisor:
  pkg:
{%- if pillar['scality'] is defined and pillar['scality']['version'] is defined %}
    - version: {{ salt['pillar.get']('scality:version') }}
    - installed
{%- else %}
    - latest
{%- endif %}
    - require:
      - pkgrepo: scality-repository
  service:
    - running
    - enable: true
    - watch:
      - pkg: scality-supervisor

{{ scality.apache_name }}:
  service:
    - running
    - enable: True
    - require:
      - pkg: scality-supervisor

check-supervisor-listening:
  scality_supervisor.listening:
    - watch:
      - service: scality-supervisor
      - service: ntpd

scality-supervisor-config:
  scality_supervisor.configured:
    - values:
        ov_core_logs:
          logsdir: {{ log_base }}/scality-supervisor
          logsoccurrences: 48
          logsmaxsize: 2000
    - require:
      - scality_supervisor: check-supervisor-listening

{% set rings = scality.rings.split(',') %}

{%- for ring in rings %}
create-ring-{{ ring }}:
  scality_ring.present:
    - name: {{ ring }}
    - require:
      - scality_supervisor: check-supervisor-listening
      - pkg: python-scalitycs
{% endfor %}
