include:
  - debconf
  - rsyslog
  - scality.sagentd

{%- set prod_ip = salt['network.ip_addrs'](interface=pillar['prod_iface'])[0] %}
{%- set name_prefix = grains['id'] + '-c' %}
{%- if grains['os_family'] == 'Debian' %}
scality-rest-connector-debconf:
  debconf.set:
    - name: scality-rest-connector
    - data:
        scality-rest-connector/supervisor-ip: {'type': 'string', 'value': {{pillar['supervisor_ip']}}}
        scality-rest-connector/disable-default-apache-ports: {'type': 'boolean', 'value': False}
        scality-rest-connector/use-ssl: {'type': 'boolean', 'value': False}
        scality-rest-connector/connector-ip: {'type': 'string', 'value': {{prod_ip}}}
        scality-rest-connector/accept-license: {'type': 'boolean', 'value': True}
        scality-rest-connector/setup-sagentd: {'type': 'boolean', 'value': True}
        scality-rest-connector/keep-config: {'type': 'boolean', 'value': True}
        scality-rest-connector/name-prefix: {'type': 'string', 'value': {{name_prefix}} }
        scality-rest-connector/restart: {'type': 'boolean', 'value': False}
    - require:
      - pkg: debconf-utils
{%- endif %}
scality-rest-connector:
  pkg:
    - installed
    - require:
      - pkg: scality-sagentd
{%- if grains['os_family'] == 'Debian' %}
      - debconf: scality-sagentd-debconf
{%- endif %}
{%- if grains['os_family'] == 'RedHat' %}
  cmd.run:
    - name: echo -e "yy\n\n\n" | /usr/local/bin/scality-rest-connector-config -m {{name_prefix}} -i {{prod_ip}}
    - template: jinja
    - unless: test -d /etc/scality-rest-connector
    - require:
      - pkg: scality-rest-connector
{%- endif %}
  service:
    - enabled
#    - running
#    - enable: true
#    - watch:
#      - pkg: scality-rest-connector

scality-rest-connector-config:
  file:
    - managed
    - template: jinja
    - name: /tmp/rest-connector-conf.tmpl
    - source: salt://scality/rest-connector/conf.tmpl
  cmd.run:
    - watch:
      - file: /tmp/rest-connector-conf.tmpl
    - name: /usr/local/bin/ringsh -f /tmp/rest-connector-conf.tmpl
    #- name: cat /tmp/rest-connector-conf.tmpl

/etc/rsyslog.d/scality-conn.conf:
  file:
    - managed
    - source : salt://scality/rest-connector/rsyslog.conf

extend:
  rsyslog:
    service:
      - watch:
        - file: /etc/rsyslog.d/scality-conn.conf

