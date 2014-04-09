
{% from "scality/map.jinja" import scality with context %}

{% if scality.config_rsyslog %}

/etc/rsyslog.d/scality-srebuildd.conf:
  file:
    - managed
    - template: jinja
    - source: salt://scality/srebuildd/rsyslog.conf.tmpl

extend:
  rsyslog:
    service:
      - watch:
        - file: /etc/rsyslog.d/scality-srebuildd.conf

{% endif %}
