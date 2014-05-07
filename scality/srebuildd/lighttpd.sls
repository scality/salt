
include:
    - scality.srebuildd
    - scality.sd.lighttpd

extend:
    scality-srebuildd:
        pkg:
            - name: scality-srebuildd-lighttpd
        service:
          - watch:
            - pkg: scality-srebuildd-lighttpd
        file:
          - require:
            - pkg: scality-srebuildd-lighttpd
    sd-lighttpd-frontend:
        service:
          - watch:
            - pkg: scality-srebuildd-lighttpd
            - file: scality-srebuildd-lighttpd-conf

scality-srebuildd-lighttpd-conf:
  file.append:
    - name: /etc/lighttpd/lighttpd.conf
    - text: include "conf.d/srebuildd.conf"

