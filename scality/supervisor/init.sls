
{% from "scality/map.jinja" import scality with context %}

include:
  - scality.req
  - scality.repo
  - scality.python

{%- set log_base = salt['pillar.get']('scality:log:base_dir', '/var/log') %}

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
{%- if pillar['scality'] is defined and pillar['scality']['version'] is defined %}
    - version: {{ salt['pillar.get']('scality:version') }}
    - installed
{%- else %}
    - latest
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

{{ scality.apache_name }}:
  service:
    - running
    - enable: True
    - require:
      - pkg: scality-supervisor

check-supervisor-listening:
  scality_supervisor.listening:
    - require:
      - service: scality-supervisor
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

{% set rings = salt['pillar.get']('scality:rings', 'RING').split(',') %}

{%- for ring in rings %}
{{ ring }}:
  scality_ring.present:
    - require:
      - scality_supervisor: check-supervisor-listening
      - pkg: python-scalitycs
{% endfor %}
