include:
  - scality.req
  - scality.repo

{%- set supervisor_ip = salt['pillar.get']('scality:supervisor_ip', '127.0.0.1') %}
{%- set prod_iface = salt['pillar.get']('scality:prod_iface', 'eth0') %}
{%- set prod_ip = salt['network.ip_addrs'](interface=prod_iface)[0] %}

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
{%- if pillar['scality'] is defined and pillar['scality']['version'] is defined %}
    - version: {{ salt['pillar.get']('scality:version') }}
    - installed
{%- else %}
    - latest
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
    - enable: True
    - require:
      - pkg: scality-sagentd
      - service: ntpd
    - watch:
      - pkg: scality-sagentd
      - file: /etc/sagentd.yaml

# register sagentd with the supervisor
register-{{grains['id']}}:
  scality_server:
    - registered
    - name: {{ grains['id'] }}
    - address: {{ prod_ip }}
    - require:
      - pkg: python-scalitycs
      - service: scality-sagentd
