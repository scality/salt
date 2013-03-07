include:
  - ntp
  - scality.sagentd

scality-node:
{%- if grains['os_family'] == 'Debian' %}
  file:
    - managed
    - template: jinja
    - name: /tmp/node.selections
    - source: salt://scality/node/node.selections
{%- endif %}
  pkg:
    - installed
    - require:
        - pkg: scality-sagentd
{%- if grains['os_family'] == 'Debian' %}
        - file: /tmp/node.selections
    - debconf: file:///tmp/node.selections
{%- endif %}
{%- if grains['os_family'] == 'RedHat' %}
  cmd.run:
    - name: /usr/local/bin/scality-node-config -p {{ pillar['mount_prefix'] }} -d {{ pillar['nb_disks'] }} -n {{ pillar['nb_nodes'] }} -m '{{ grains['id'] }}-n' -i {{ salt['network.ip_addrs']()[0] }}
    - template: jinja
    - unless: test -d /etc/scality-node-1
    - require:
      - pkg: scality-node
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
