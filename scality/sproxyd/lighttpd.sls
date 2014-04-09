
include:
    - scality.sproxyd
    - scality.sd.lighttpd

extend:
    scality-sproxyd:
        pkg:
            - name: scality-sproxyd-lighttpd
        service:
          - watch:
            - pkg: scality-sproxyd-lighttpd

scality-sproxyd-lighttpd-conf:
  file.append:
    - name: /etc/lighttpd/lighttpd.conf
    - text: include "conf.d/sproxyd.conf"

