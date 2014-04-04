
include:
  - scality.req
  - scality.repo
  - scality.python

/ring:
  file:
    - directory
    - user: root
    - group: root
    - mode: 755

sfused:
  pkg:
    - name: scality-sfused
{%- if pillar['scality'] is defined and pillar['scality']['version'] is defined %}
    - version: {{ salt['pillar.get']('scality:version') }}
    - installed
{%- else %}
    - latest
{%- endif %}
    - require:
      - pkgrepo: scality-repository
  file:
    - managed
    - name: /etc/sfused.conf
    - template: jinja
    - source: salt://scality/sfused/sfused.conf.tmpl
    - defaults:
        mem_total_bytes: {{ grains['mem_total'] * 1024 * 1024 }}
        metadata_ring: META
        sproxyd_addresses:
{%- for host, hostinfo in salt['mine.get']('*', 'grains.items').items() %}
{%- if hostinfo.has_key('scality_sproxyd_address') %}
          - {{ hostinfo['scality_sproxyd_address'] }}
{%- endif %}
{%- endfor %}
    - require:
      - pkg: python-scalitycs
  service:
    - running
    - enable: True
    - name: scality-sfused
    - watch:
      - file: /etc/sfused.conf
      - file: /ring

{% if  salt['pillar.get']('scality:config_rsyslog', True) %}
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


