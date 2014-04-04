
# do not include this state directly, use either scality.sindexd.lighttpd or scality.sindexd.apache instead

include:
  - scality.req
  - scality.repo
  - scality.python

sindexd:
  pkg:
{%- if pillar['scality'] is defined and pillar['scality']['version'] is defined %}
    - version: {{ salt['pillar.get']('scality:version') }}
    - installed
{%- else %}
    - latest
{%- endif %}
    - name: scality-sindexd
    - require:
      - pkgrepo: scality-repository
  service:
    - running
    - enable: True
    - name: scality-sindexd
    - watch:
      - file: sindexd
  file:
    - managed
    - name: /etc/sindexd.conf
    - template: jinja
    - source: salt://scality/sindexd/sindexd.conf.tmpl
    - require:
      - pkg: python-scalitycs

{% if  salt['pillar.get']('scality:config_rsyslog', True) %}
/etc/rsyslog.d/scality-sindexd.conf:
  file:
    - managed
    - template: jinja
    - source: salt://scality/sindexd/rsyslog.conf.tmpl

extend:
  rsyslog:
    service:
      - watch:
        - file: /etc/rsyslog.d/scality-sindexd.conf
{% endif %}
