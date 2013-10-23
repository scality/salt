
# helper for all scality.s*d.lighttpd states

sd-lighttpd-frontend:
  service:
    - running
    - name: lighttpd
    - watch:
      - file: /etc/lighttpd/lighttpd.conf

sd-lighttpd-port:
  file.replace:
    - name: /etc/lighttpd/lighttpd.conf
    - pattern: 'server.port = .*'
    - repl: 'server.port = 81'

sd-lighttpd-ipv6:
  file.replace:
    - name: /etc/lighttpd/lighttpd.conf
    - pattern: 'server.use-ipv6 = "enable"'
    - repl: 'server.use-ipv6 = "disable"'

sd-lighttpd-fastcgi:
  file.append:
    - name: /etc/lighttpd/lighttpd.conf
    - text: include "conf.d/fastcgi.conf"

