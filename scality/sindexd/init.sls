include:
  - scality.ringsh

lighttpd:
  pkg:
    - installed
    - names:
        - lighttpd
{%- if grains['os_family'] == 'RedHat' %}
        - lighttpd-fastcgi
{%- endif %}
  service:
    - running
    - name: lighttpd
    - watch:
       - file: /etc/lighttpd/lighttpd.conf
       - file: /etc/lighttpd/modules.conf

/etc/lighttpd/lighttpd.conf:
  file:
    - managed
    - source: salt://scality/sindexd/lighttpd.conf

/etc/lighttpd/modules.conf:
  file:
    - managed
    - source: salt://scality/sindexd/modules.conf

scality-sindexd:
  pkg:
    - installed
{%- if pillar['scality'] is defined and pillar['scality']['version'] is defined %}
    - version: {{ salt['pillar.get']('scality:version') }}
{%- endif %}
    - names:
        - scality-sindexd
        - lighttpd
        - scality-ringsh
        - python-scalitycs
    - require:
      - pkgrepo: scality-repository
  service:
    - running
    - name: scality-sindexd
    - watch:
      - file: scality-sindexd
  file:
    - managed
    - name: /etc/sindexd.conf
    - template: jinja
    - source: {{ salt['pillar.get']('scality:sindexd_conf_tmpl', 'salt://scality/sindexd/sindexd.conf.tmpl')}}
    - require:
      - file: scality-ringsh

