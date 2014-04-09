
{% from "scality/map.jinja" import scality with context %}

include:
    - scality.sindexd
    - scality.sd.apache

extend:
    scality-sindexd:
        pkg:
            - name: scality-sindexd-{{ scality.apache_name }}
        service:
            - watch:
              - pkg: scality-sindexd-{{ scality.apache_name }}

