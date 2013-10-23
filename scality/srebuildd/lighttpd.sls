
include:
    - scality.srebuildd
    - scality.sd.lighttpd

extend:
    srebuildd:
        pkg:
            - name: scality-srebuildd-lighttpd
        service:
            - name: scality-srebuildd-lighttpd

srebuildd-lighttpd-conf:
  file.append:
    - name: /etc/lighttpd/lighttpd.conf
    - text: include "conf.d/srebuildd.conf"

