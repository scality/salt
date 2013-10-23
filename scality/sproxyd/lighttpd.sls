
include:
    - scality.sproxyd
    - scality.sd.lighttpd

extend:
    sproxyd:
        pkg:
            - name: scality-sproxyd-lighttpd
        service:
            - name: scality-sproxyd-lighttpd

sproxyd-lighttpd-conf:
  file.append:
    - name: /etc/lighttpd/lighttpd.conf
    - text: include "conf.d/sproxyd.conf"

