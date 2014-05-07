
{% from "scality/map.jinja" import scality with context %}

{% if scality.config_rsyslog %}

/etc/rsyslog.d/scality-sfused.conf:
  file:
    - managed
    - template: jinja
    - source: salt://scality/sfused/rsyslog.conf.tmpl

extend:
  rsyslog:
    service:
      - watch:
        - file: /etc/rsyslog.d/scality-sfused.conf

{% endif %}
