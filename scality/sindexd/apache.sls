
{% from "scality/map.jinja" import apache with context %}

include:
    - scality.sindexd
    - scality.sd.apache

extend:
    sindexd:
        pkg:
            - name: scality-sindexd-{{ apache.name }}
        service:
            - watch:
              - pkg: scality-sindexd-{{ apache.name }}

