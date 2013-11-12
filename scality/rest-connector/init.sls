include:
  - scality.req
  - scality.repo
  - scality.sagentd
  - scality.ringsh

{%- set supervisor_ip = salt['pillar.get']('scality:supervisor_ip', '127.0.0.1') %}
{%- set prod_iface = salt['pillar.get']('scality:prod_iface', 'eth0') %}
{%- set prod_ip = salt['network.ip_addrs'](interface=prod_iface)[0] %}
{%- set name_prefix = grains['id'] + '-c' %}
{%- if grains['os_family'] == 'Debian' %}
scality-rest-connector-debconf:
  debconf.set:
    - name: scality-rest-connector
    - data:
        scality-rest-connector/supervisor-ip: {'type': 'string', 'value': {{ supervisor_ip }}}
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
{%- if pillar['scality'] is defined and pillar['scality']['version'] is defined %}
    - version: {{ salt['pillar.get']('scality:version') }}
{%- endif %}
    - require:
      - pkgrepo: scality-repository
      - pkg: scality-sagentd
{%- if grains['os_family'] == 'Debian' %}
      - debconf: scality-sagentd-debconf
{%- endif %}
{%- if grains['os_family'] == 'RedHat' %}
  cmd.run:
    - name: echo -e "yy\n\n\n" | /usr/local/bin/scality-rest-connector-config -m {{ name_prefix }} -i {{ prod_ip }}
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

wait-for-rest-connector-startup:
  cmd.wait:
    - name: sleep 10
    - watch:
{%- if grains['os_family'] == 'RedHat' %}
      - cmd: scality-rest-connector
{%- endif %}
{%- if grains['os_family'] == 'Debian' %}
      - pkg: scality-rest-connector
{%- endif %}

{% set data_ring = salt['pillar.get']('scality:rings', 'RING').split(',')[0] %}

add-rest-connector:
  scality_rest_connector.added:
    - name: {{ name_prefix }}1
    - ring: {{ data_ring }}
    - supervisor: {{ supervisor_ip }}
    - require:
      - scality_server: register-{{grains['id']}}

config-rest-connector:
  scality_rest_connector.configured:
    - name: {{ name_prefix }}1
    - ring: {{ data_ring }}
    - supervisor: {{ supervisor_ip }}
    - values:
        msgstore_protocol_restapi:
          bwsdeferredpolicy: -1
          bwsdrvdata: arc
          chordsplitsizetrigger: 4000000
          chordsplitsizeblock: 2000000
          bwssplitsizetrigger: 4000000
          bwssplitsizeblock: 2000000
        msgstore_storage_chordbucket:
          bwsdbmesamaincos: 4
          bwsdbmesacos: 2
          bwsdbmesahost: 127.0.0.1:81
          bwsdbmesauri: /sindexd.fcgi
        ov_core_logs:
          logsoccurrences: 48
          logsmaxsize: 2000
        ov_protocol_dns:
          mainresolver: 127.0.0.1
        ov_protocol_netscript:
          connect timeout: 5
          socket timeout: 30
    - require:
      - scality_rest_connector: add-rest-connector

#{%- if pillar['nodes'] is defined %}
#accessor configSet msgstore_protocol_restapi bwsdrvdataopts "sproxyd_srv=
#{%- for node in salt['pillar.get']('nodes', '') -%}
#{{node}}:81
#{%- if not loop.last -%}
#,
#{%- endif -%}
#{%- endfor -%}
#;sproxyd_uri_arc=/proxy/arc;sproxyd_uri_chord=/proxy/chord"
#{%- endif %}


/etc/rsyslog.d/scality-conn.conf:
  file:
    - managed
    - source : salt://scality/rest-connector/rsyslog.conf

extend:
  rsyslog:
    service:
      - watch:
        - file: /etc/rsyslog.d/scality-conn.conf

