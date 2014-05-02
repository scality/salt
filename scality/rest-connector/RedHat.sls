
include:
  - scality.repo
  - scality.sagentd

{% from "scality/map.jinja" import scality with context %}

{%- set prod_ip = salt['network.ip_addrs'](interface=scality.prod_iface)[0] %}

extend:
  scality-rest-connector:
    cmd.run:
      - name: >
                echo -e "yy\n\n\n" | 
                /usr/local/bin/scality-rest-connector-config 
                -m {{ scality.ctor_name_prefix }} 
                -i {{ prod_ip }}
      - template: jinja
      - unless: test -d /etc/scality-rest-connector
      - env:
        - SCALITY_AUTH_FILE: /tmp/scality-installer-credentials
      - require:
        - pkg: scality-rest-connector
        - file: /tmp/scality-installer-credentials
    service:
      - require:
        - cmd: scality-rest-connector
