
# do not include this state directly, use either scality.srebuildd.lighttpd or scality.srebuildd.apache instead

include:
  - scality.req
  - scality.repo
  - scality.python

srebuildd:
  pkg:
{%- if pillar['scality'] is defined and pillar['scality']['version'] is defined %}
    - version: {{ salt['pillar.get']('scality:version') }}
    - installed
{%- else %}
    - latest
{%- endif %}
    - name: scality-srebuildd
    - require:
      - pkgrepo: scality-repository
  service:
    - running
    - enable: True
    - name: scality-srebuildd
    - watch:
      - file: srebuildd
  file:
    - managed
    - name: /etc/srebuildd.conf
    - template: jinja
    - source: salt://scality/srebuildd/srebuildd.conf.tmpl
    - require:
      - pkg: python-scalitycs

{% if  salt['pillar.get']('scality:config_rsyslog', True) %}
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
