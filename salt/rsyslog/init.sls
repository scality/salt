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
      - file: /etc/rsyslog.d/scality-nodes.conf

/etc/rsyslog.conf:
  file:
    - managed
    - source : salt://rsyslog/rsyslog.conf

/etc/rsyslog.d/scality-nodes.conf:
  file:
    - managed
    - source : salt://rsyslog/scality-nodes.conf
