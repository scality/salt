
{% from "scality/map.jinja" import scality with context %}

include:
    - scality.sproxyd
    - scality.sd.apache

extend:
    sproxyd:
        pkg:
            - name: scality-sproxyd-{{ scality.apache_name }}
        service:
          - watch:
            - pkg: scality-sproxyd-{{ scality.apache_name }}

