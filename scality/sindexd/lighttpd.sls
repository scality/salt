
include:
    - scality.sindexd
    - scality.sd.lighttpd

extend:
    scality-sindexd:
        pkg:
            - name: scality-sindexd-lighttpd
        service:
          - watch:
            - pkg: scality-sindexd-lighttpd

scality-sindexd-lighttpd-conf:
  file.append:
    - name: /etc/lighttpd/lighttpd.conf
    - text: include "conf.d/sindexd.conf"

