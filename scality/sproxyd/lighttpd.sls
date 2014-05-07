
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
        file:
          - require:
            - pkg: scality-sproxyd-lighttpd
    sd-lighttpd-frontend:
        service:
          - watch:
            - pkg: scality-sproxyd-lighttpd
            - file: scality-sproxyd-lighttpd-conf

scality-sproxyd-lighttpd-conf:
  file.append:
    - name: /etc/lighttpd/lighttpd.conf
    - text: include "conf.d/sproxyd.conf"

