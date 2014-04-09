
include:
  - scality.repo
  - scality.sagentd

{% from "scality/map.jinja" import scality with context %}

{%- set prod_ip = salt['network.ip_addrs'](interface=scality.prod_iface)[0] %}

extend:
  scality-node:
    cmd.run:
      - name: > 
                /usr/local/bin/scality-node-config 
                -p {{ scality.mount_prefix }} 
                -d {{ scality.nb_disks }} 
                -n {{ scality.nb_nodes }} 
                -m {{ scality.name_prefix }} 
                -I {{ prod_ip }}
      - template: jinja
      - unless: test -d /etc/scality-node-1
      - require:
        - pkg: scality-node
        - host: {{ grains['id'] }}
    service:
      - require:
        - cmd: scality-node

  