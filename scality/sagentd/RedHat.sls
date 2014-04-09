
{% from "scality/map.jinja" import scality with context %}

{%- set prod_ip = salt['network.ip_addrs'](interface=scality.prod_iface)[0] %}

extend:
  scality-sagentd:
    cmd.run:
      - name: /usr/local/bin/scality-sagentd-config -u {{ scality.supervisor_ip }}
      - template: jinja
      - unless: grep -q {{ scality.supervisor_ip }} /etc/sagentd.yaml
      - require:
        - pkg: scality-sagentd
    service:
      - require:
        - cmd: scality-sagentd
