
{% if  salt['pillar.get']('scality:config_logrotate', True) %}
logrotate:
  pkg:
    - installed
  file.managed:
    - name: /etc/logrotate.d/scality
    - template: jinja
    - source : salt://scality/req/logrotate/logrotate.tmpl
{% endif %}
