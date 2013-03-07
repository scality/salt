rsyslog:
  pkg.installed

rsyslog:
  service.running:
{% if grains['os_family'] == 'Debian' %}
    - name: rsyslog
{% endif %}
    - enable: True
    - watch:
      - file: /etc/rsyslog.conf
      - file: /etc/rsyslog.d/scality-conn.conf

/etc/rsyslog.conf:
  file:
    - managed
    - source : salt://rsyslog-conn/rsyslog.conf

/etc/rsyslog.d/scality-conn.conf:
  file:
    - managed
    - source : salt://rsyslog-conn/scality-conn.conf
