
srebuildd:
  pkg:
    - installed
    - name: scality-srebuildd-httpd
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

