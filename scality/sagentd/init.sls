include:
  - scality.req
  - scality.repo

{%- set supervisor_ip = salt['pillar.get']('scality:supervisor_ip', '127.0.0.1') %}

{%- if grains['os_family'] == 'Debian' %}
scality-sagentd-debconf:
  debconf.set:
    - name: scality-sagentd
    - data:
        scality-sagentd/supervisor-ip: {'type': 'string', 'value': {{ supervisor_ip }}}
    - require:
      - pkg: debconf-utils
{%- endif %}
scality-sagentd:
  pkg:
    - installed
{%- if pillar['scality'] is defined and pillar['scality']['version'] is defined %}
    - version: {{ salt['pillar.get']('scality:version') }}
{%- endif %}
    - require:
      - pkgrepo: scality-repository
{%- if grains['os_family'] == 'Debian' %}
      - debconf: scality-sagentd-debconf
{%- endif %}
{%- if grains['os_family'] == 'RedHat' %}
  cmd.run:
    - name: /usr/local/bin/scality-sagentd-config -u {{ supervisor_ip }}
    - template: jinja
    - unless: grep -q {{ supervisor_ip }} /etc/sagentd.yaml
    - require:
      - pkg: scality-sagentd
{%- endif %}
  file:
    - exists
    - name: /etc/sagentd.yaml
    - require:
      - pkg: scality-sagentd
  service:
    - running
    - require:
      - pkg: scality-sagentd
    - watch:
      - pkg: scality-sagentd
      - file: /etc/sagentd.yaml

