
{% from "scality/map.jinja" import scality with context %}

include:
    - scality.sproxyd
    - scality.sd.apache

extend:
    scality-sproxyd:
        pkg:
            - name: scality-sproxyd-{{ scality.apache_name }}
        service:
          - watch:
            - pkg: scality-sproxyd-{{ scality.apache_name }}
        file:
          - require:
            - pkg: scality-sproxyd-{{ scality.apache_name }}
    sd-apache-frontend:
        service:
          - watch:
            - pkg: scality-sproxyd-{{ scality.apache_name }}

