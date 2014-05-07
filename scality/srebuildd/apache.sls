
{% from "scality/map.jinja" import scality with context %}

include:
    - scality.srebuildd
    - scality.sd.apache

extend:
    scality-srebuildd:
        pkg:
            - name: scality-srebuildd-{{ scality.apache_name }}
        service:
          - watch:
            - pkg: scality-srebuildd-{{ scality.apache_name }}
        file:
          - require:
            - pkg: scality-srebuildd-{{ scality.apache_name }}
    sd-apache-frontend:
        service:
          - watch:
            - pkg: scality-srebuildd-{{ scality.apache_name }}

