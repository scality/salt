
{% from "scality/map.jinja" import apache with context %}

include:
    - scality.sproxyd
    - scality.sd.apache

extend:
    sproxyd:
        pkg:
            - name: scality-sproxyd-{{ apache.name }}
        service:
          - watch:
            - pkg: scality-sproxyd-{{ apache.name }}

