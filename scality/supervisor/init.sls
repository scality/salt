include:
  - scality.req
  - scality.repo

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
{%- if pillar['scality:version'] is defined %}
    - version: {{ salt['pillar.get']('scality:version') }}
{%- endif %}
    - require:
      - pkgrepo: scality-repository
{%- if grains['os_family'] == 'Debian' %}
      - debconf: scality-supervisor-debconf
{%- endif %}
{%- if grains['os_family'] == 'RedHat' %}
  cmd.run:
    - name: echo "y" | /usr/local/bin/scality-supervisor-config 
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
httpd:
{%- else %}
apache2:
{%- endif %}
  service:
    - running
    - enable: True
    - require:
      - pkg: scality-supervisor


{%- for ring in ('scality:data_ring', 'scality:metadata_ring') %}
{{ salt['pillar.get'](ring, 'RING') }}:
  scality_ring.present:
    - supervisor: {{ supervisor_ip }} 
    - require:
      - service: scality-supervisor
{% endfor %}
