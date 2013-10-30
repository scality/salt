
{% from "scality/map.jinja" import apache with context %}

include:
  - scality.req
  - scality.repo
  - scality.python

{% set supervisor_ip = salt['pillar.get']('scality:supervisor_ip', '127.0.0.1') %}

{%- if grains['os_family'] == 'Debian' %}
scality-supervisor-debconf:
  debconf.set:
    - name: scality-supervisor
    - data:
        scality-supervisor/accept-license: {'type': 'boolean', 'value': True}
    - require:
      - pkg: debconf-utils
{%- endif %}

scality-supervisor:
  pkg:
    - installed
{%- if pillar['scality'] is defined and pillar['scality']['version'] is defined %}
    - version: {{ salt['pillar.get']('scality:version') }}
{%- endif %}
    - require:
      - pkgrepo: scality-repository
{%- if grains['os_family'] == 'Debian' %}
      - debconf: scality-supervisor-debconf
{%- endif %}
{%- if grains['os_family'] == 'RedHat' %}
  cmd.run:
    - name: echo "y" | /usr/local/bin/scality-supervisor-config && sleep 5
    - template: jinja
    - unless: test -d /etc/scality-supervisor
    - require:
      - pkg: scality-supervisor
{%- endif %}
  service:
    - running
    - watch:
      - pkg: scality-supervisor
{%- if grains['os_family'] == 'RedHat' %}
    - require:
      - pkg: scality-supervisor
      - cmd: scality-supervisor
{%- endif %}

{{ apache.name }}:
  service:
    - running
    - enable: True
    - require:
      - pkg: scality-supervisor

scality-supervisor-config:
  scality_supervisor.configured:
    - supervisor: {{ supervisor_ip }}
    - values:
        ov_core_logs:
          logsoccurrences: 48
          logsmaxsize: 2000
    - require:
      - service: scality-supervisor

{% set rings = salt['pillar.get']('scality:rings', 'RING').split(',') %}

{%- for ring in rings %}
{{ ring }}:
  scality_ring.present:
    - supervisor: {{ supervisor_ip }} 
    - require:
      - service: scality-supervisor
      - pkg: python-scalitycs
{% endfor %}
