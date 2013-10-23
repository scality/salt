include:
  - scality.req
  - scality.repo
  - scality.sagentd
  - scality.req.rsyslog
  - scality.req.hosts
  - scality.python

{%- set supervisor_ip = salt['pillar.get']('scality:supervisor_ip', '127.0.0.1') %}
{%- set prod_iface = salt['pillar.get']('scality:prod_iface', 'eth0') %}
{%- set nb_nodes = salt['pillar.get']('scality:nb_nodes', 6) %}
{%- set mount_prefix = salt['pillar.get']('scality:mount_prefix', '/scality/disk') %}
{%- set nb_disks = salt['pillar.get']('scality:nb_disks', 1) %}
{%- set name_prefix = salt['pillar.get']('scality:name_prefix', grains['id'] + '-n') %}

{%- set prod_ip = salt['network.ip_addrs'](interface=prod_iface)[0] %}

{%- if grains['os_family'] == 'Debian' %}
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
        scality-node/setup-sagentd: {'type': 'boolean', 'value': False}
        scality-node/restart: {'type': 'boolean', 'value': False}
    - require:
      - pkg: debconf-utils
{%- endif %}
scality-node:
  pkg:
    - installed
{%- if pillar['scality'] is defined and pillar['scality']['version'] is defined %}
    - version: {{ salt['pillar.get']('scality:version') }}
{%- endif %}
    - require:
      - pkgrepo: scality-repository
      - pkg: scality-sagentd
{%- if grains['os_family'] == 'Debian' %}
      - debconf: scality-node-debconf
{%- endif %}
{%- if grains['os_family'] == 'RedHat' %}
  cmd.run:
    - name: /usr/local/bin/scality-node-config -p {{ mount_prefix }} -d {{ nb_disks }} -n {{ nb_nodes }} -m {{ name_prefix }} -i {{ prod_ip }}
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
      - file: /etc/sysconfig/scality-node
      - pkg: scality-node

scality-node-config:
  file:
    - managed
    - template: jinja
    - name: /tmp/node-conf.tmpl
    - source: salt://scality/node/conf.tmpl
  cmd.run:
    - watch:
      - file: /tmp/node-conf.tmpl
    - require:
{%- for node in range(nb_nodes) %}
      - scality_node: {{grains['id']}}-n{{loop.index}}
{% endfor %}
    - name: /usr/local/bin/ringsh -f /tmp/node-conf.tmpl
    #- name: cat /tmp/node-conf.tmpl

/etc/sysconfig/scality-node:
    file:
      - managed
      - source : salt://scality/node/scality-node

/etc/rsyslog.d/scality-nodes.conf:
  file:
    - managed
    - source : salt://scality/node/rsyslog.conf

extend:
  rsyslog:
    service:
      - watch:
        - file: /etc/rsyslog.d/scality-nodes.conf

register-{{grains['id']}}:
  scality_node:
    - registered
    - name: {{ grains['id'] }}
    - address: {{ prod_ip }}
    - supervisor: {{ supervisor_ip }}
    - require:
      - pkg: python-scalitycs
      - service: scality-sagentd
      
{% set data_ring = salt['pillar.get']('scality:rings', 'RING').split(',')[0] %}

{%- for node in range(nb_nodes) %}
{{grains['id']}}-n{{loop.index}}:
  scality_node.added:
    - ring: {{ data_ring }} 
    - supervisor: {{ supervisor_ip }} 
    - require:
      - scality_node: register-{{grains['id']}}
{% endfor %}


