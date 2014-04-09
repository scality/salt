
{% from "scality/map.jinja" import scality with context %}

{% if scality.config_rsyslog %}

/etc/rsyslog.d/scality-sproxyd.conf:
  file:
    - managed
    - template: jinja
    - source: salt://scality/sproxyd/rsyslog.conf.tmpl

extend:
  rsyslog:
    service:
      - watch:
        - file: /etc/rsyslog.d/scality-sproxyd.conf

{% endif %}
