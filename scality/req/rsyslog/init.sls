rsyslog:
  pkg:
    - installed
  service.running:
    - enable: True
    - watch:
      - file: /etc/rsyslog.conf
  file.managed:
    - name: /etc/rsyslog.conf
    - source : salt://scality/req/rsyslog/rsyslog.conf
