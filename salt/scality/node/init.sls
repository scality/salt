include:
  - debconf
  - ntp
  - rsyslog
  - scality.sagentd
  - scality.hosts

{%- set prod_ip = salt['network.ip_addrs'](interface=pillar['prod_iface'])[0] %}
{%- set name_prefix = grains['id'] + '-n' %}
{%- if grains['os_family'] == 'Debian' %}
scality-node-debconf:
  debconf.set:
    - name: scality-node
    - data:
        scality-node/node-ip: {'type': 'string', 'value': {{prod_ip}}}
        scality-node/processes-count: {'type': 'string', 'value': {{pillar['nb_nodes']}}}
        scality-node/accept-license: {'type': 'boolean', 'value': True}
        scality-node/mount-prefix: {'type': 'string', 'value': {{pillar['mount_prefix']}}}
        scality-node/biziod-count: {'type': 'string', 'value': {{pillar['nb_disks']}}}
        scality-node/use-ssl: {'type': 'boolean', 'value': False}
        scality-node/name-prefix: {'type': 'string', 'value': {{name_prefix}}}
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
    - require:
      - pkg: scality-sagentd
{%- if grains['os_family'] == 'Debian' %}
      - debconf: scality-node-debconf
{%- endif %}
{%- if grains['os_family'] == 'RedHat' %}
  cmd.run:
    - name: /usr/local/bin/scality-node-config -p {{pillar['mount_prefix']}} -d {{pillar['nb_disks']}} -n {{pillar['nb_nodes']}} -m {{name_prefix}} -i {{prod_ip}}
    - template: jinja
    - unless: test -d /etc/scality-node-1
    - require:
      - pkg: scality-node
      - host: {{grains['id']}}
{%- endif %}
  service:
    - enabled
    - watch:
      - file: /etc/sysconfig/scality-node
# cannot specify running, hang because bizstorenode does not detach from its terminal
#- running
#- enable: true
#- sig: bizstorenode
#- watch:
#  - pkg: scality-node

scality-node-config:
  file:
    - managed
    - template: jinja
    - name: /tmp/node-conf.tmpl
    - source: salt://scality/node/conf.tmpl
  cmd.run:
    - watch:
      - file: /tmp/node-conf.tmpl
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

