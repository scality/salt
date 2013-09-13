
srebuildd:
  pkg:
    - installed
{%- if pillar['scality:version'] is defined %}
    - version: {{ salt['pillar.get']('scality:version') }}
{%- endif %}
    - name: scality-srebuildd-httpd
    - require:
      - pkgrepo: scality-repository
  service:
    - running
    - name: scality-srebuildd
    - watch:
      - pkg: scality-srebuildd-httpd
      - file: srebuildd
  file:
    - managed
    - name: /etc/srebuildd.conf
    - source: salt://scality/generated/srebuildd.conf

