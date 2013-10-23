
{% from "scality/map.jinja" import apache with context %}

include:
    - scality.srebuildd
    - scality.sd.apache

extend:
    sproxyd:
        pkg:
            - name: scality-srebuildd-{{ apache.name }}
        service:
          - watch:
            - pkg: scality-srebuildd-{{ apache.name }}

