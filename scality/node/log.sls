
{% from "scality/map.jinja" import scality with context %}

{% if  scality.config_rsyslog %}

include:
  - scality.req.rsyslog

/etc/rsyslog.d/scality-biziod.conf:
  file:
    - managed
    - template: jinja
    - source : salt://scality/node/rsyslog.conf.tmpl

extend:
  rsyslog:
    service:
      - watch:
        - file: /etc/rsyslog.d/scality-biziod.conf

{%- endif %}
