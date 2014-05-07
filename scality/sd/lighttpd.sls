
# helper for all scality.s*d.lighttpd states

sd-lighttpd-frontend:
  service:
    - running
    - name: lighttpd
    - enable: True
    - watch:
      - file: /etc/lighttpd/lighttpd.conf

sd-lighttpd-set-port-81:
  file.replace:
    - name: /etc/lighttpd/lighttpd.conf
    - pattern: 'server.port = .*'
    - repl: 'server.port = 81'

sd-lighttpd-disable-ipv6:
  file.replace:
    - name: /etc/lighttpd/lighttpd.conf
    - pattern: 'server.use-ipv6 = "enable"'
    - repl: 'server.use-ipv6 = "disable"'

sd-lighttpd-enable-fastcgi:
  file.append:
    - name: /etc/lighttpd/lighttpd.conf
    - text: include "conf.d/fastcgi.conf"

