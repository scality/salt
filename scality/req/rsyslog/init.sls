
{%- set log_base = salt['pillar.get']('scality:log:base_dir', '/var/log') %}

{{ log_base }}:
  file:
    - directory
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{% if  salt['pillar.get']('scality:config_rsyslog', True) %}
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
{% endif %}
