rsyslog:
  pkg.installed

rsyslog:
  service.running:
    - enable: True
    - watch:
      - file: /etc/rsyslog.conf

/etc/rsyslog.conf:
  file:
    - managed
    - source : salt://rsyslog/rsyslog.conf
