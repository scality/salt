include:
  - scality.req
  - scality.repo
  - scality.sagentd
  - scality.req.rsyslog
  - scality.req.hosts
  - scality.python

{% from "scality/map.jinja" import scality with context %}

{%- set supervisor_ip = salt['pillar.get']('scality:supervisor_ip', '127.0.0.1') %}
{%- set prod_iface = salt['pillar.get']('scality:prod_iface', 'eth0') %}
{%- set nb_nodes = salt['pillar.get']('scality:nb_nodes', 6) %}
{%- set mount_prefix = salt['pillar.get']('scality:mount_prefix', '/scality/disk') %}
{%- set nb_disks = salt['pillar.get']('scality:nb_disks', 1) %}
{%- set name_prefix = salt['pillar.get']('scality:name_prefix', grains['id'] + '-n') %}
{%- set log_base = salt['pillar.get']('scality:log:base_dir', '/var/log') %}
{%- set prod_ip = salt['network.ip_addrs'](interface=prod_iface)[0] %}

{%- if grains['os_family'] == 'Debian' %}
# scality-node-config options, Debian style
scality-node-debconf:
  debconf.set:
    - name: scality-node
    - data:
        scality-node/node-ip: {'type': 'string', 'value': {{ prod_ip }}}
        scality-node/processes-count: {'type': 'string', 'value': {{ nb_nodes }}}
        scality-node/accept-license: {'type': 'boolean', 'value': True}
        scality-node/mount-prefix: {'type': 'string', 'value': {{ mount_prefix }}}
        scality-node/biziod-count: {'type': 'string', 'value': {{ nb_disks }}}
        scality-node/use-ssl: {'type': 'boolean', 'value': False}
        scality-node/name-prefix: {'type': 'string', 'value': {{ name_prefix }}}
        scality-node/keep-config: {'type': 'boolean', 'value': True}
        scality-node/tier2-enabled: {'type': 'boolean', 'value': False}
        scality-node/warning-mount: {'type': 'boolean', 'value': True}
        scality-node/setup-sagentd: {'type': 'boolean', 'value': True}
        scality-node/restart: {'type': 'boolean', 'value': False}
    - require:
      - pkg: debconf-utils
{%- endif %}
scality-node:
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
{%- if grains['os_family'] == 'Debian' %}
      - debconf: scality-node-debconf
{%- endif %}
{%- if grains['os_family'] == 'RedHat' %}
# scality-node-config options, RedHat style
  cmd.run:
    - name: /usr/local/bin/scality-node-config -p {{ mount_prefix }} -d {{ nb_disks }} -n {{ nb_nodes }} -m {{ name_prefix }} -I {{ prod_ip }}
    - template: jinja
    - unless: test -d /etc/scality-node-1
    - require:
      - pkg: scality-node
      - host: {{ grains['id'] }}
{%- endif %}
  service:
    - running
    - enable: true
    - sig: bizstorenode
    - watch:
      - file: {{ scality.init_conf_dir }}/scality-node
      - pkg: scality-node

{{ scality.init_conf_dir }}/scality-node:
    file:
      - managed
      - source : salt://scality/node/scality-node

{% if  salt['pillar.get']('scality:config_rsyslog', True) %}
/etc/rsyslog.d/scality-biziod.conf:
  file:
    - managed
    - template: jinja
    - source : salt://scality/node/rsyslog.conf.tmpl

extend:
  rsyslog:
    service:
      - watch:
        - file: /etc/rsyslog.d/scality-biziod.conf
{%- endif %}

# cap md pool size so that it uses no more than ~4% to avoid freezing machines with not much RAM
# an md pool entry is 70 bytes, 600 is ~ 0.04 * (1024*1024) / 70
# 30000000 is OK above 52 GB of RAM
{% set maxmdpoolsize = 600 * grains['mem_total'] %}
{% set chunkapimdpoolsize = 30000000 if 30000000 < maxmdpoolsize else maxmdpoolsize %}

{% macro for_all_nodes() -%}
{% set xnodes = salt['scality.nodes']() if salt.has_key('scality.nodes') else () %}
{% for xnode in xnodes %}
{{ caller(node=xnode) }}
{% endfor %}
{%- endmacro %}

{% macro for_nodes_in(ring) -%}
{% set xnodes = salt['scality.nodes'](ring=ring) if salt.has_key('scality.nodes') else () %}
{% for xnode in xnodes %}
{{ caller(node=xnode) }}
{% endfor %}
{%- endmacro %}

{% call(node) for_all_nodes() %}

# make sure the node is listening before we try to add it
check-{{ node.name }}-listening:
  scality_node.listening:
    - address: {{ prod_ip }}
    - port: {{ node.mgmt_port }}
    - require:
      - scality_server: register-{{grains['id']}}
{%- if grains['os_family'] == 'RedHat' %}
      - cmd: scality-node
{%- endif %}
{%- if grains['os_family'] == 'Debian' %}
      - pkg: scality-node
{%- endif %}

# add the node to its ring
add-{{ node.name }}:
  scality_node.added:
    - name: {{ node.name }}
    - ring: {{ node.ring }}
    - supervisor: {{ supervisor_ip }} 
    - require:
      - scality_node: check-{{ node.name }}-listening

# set a few configuration values where the default is lacking
config-{{ node.name }}:
  scality_node.configured:
    - name: {{ node.name }}
    - ring: {{ node.ring }}
    - values:
        msgstore_protocol_chord:
          chordchecklocalnbchunks: 300
          chordctrlmaxparalleltasks: 5
          chordhttpsockettimeout: 30
          chordctrlrebuildrestbasepath: /rebuild/arcdata
        msgstore_storage_asyncpersistentmemory:
          pmmaxbiziostoreioidle: 8
          pmminbiziostoreblockdelayS: 30
          pmminbiziostoreblockdelaytimeoutS: 60
          pmminlibbizioreconnectdelaytimeoutS: 10
        msgstore_storage_chunkapi:
          chunkapimaxdelete: 32
          chunkapimaxphysdelete: 10
          chunkapimaxread: 96
          chunkapimaxwrite: 64
          chunkapimdpoolsize: {{ chunkapimdpoolsize }}
          chunkapinoatime: 1
        ov_cluster_node:
          usessl: 0
        ov_core_logs:
          logsdir: {{ log_base }}/scality-node-{{ node.index }}
          logsoccurrences: 48
          logsmaxsize: 2000
        ov_protocol_dns:
          mainresolver: 62.149.128.4,62.149.132.4
        ov_protocol_netscript:
          connect timeout: 5
          socket timeout: 30
    - require:
      - scality_node: add-{{ node.name }}

{% endcall %}

all-nodes-available:
  scality_server.available:
    - require:
{%- call(node) for_all_nodes() %}
      - scality_node: add-{{ node.name }}
{%- endcall %}
    - watch:
      - service: scality-node
