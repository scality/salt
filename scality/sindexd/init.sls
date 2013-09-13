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
    - names:
        - scality-sindexd
        - lighttpd
        - scality-ringsh
        - python-scalitycs
  service:
    - running
    - name: scality-sindexd
    - watch:
      - file: scality-sindexd
  file:
    - managed
    - name: /etc/sindexd.conf
    - template: jinja
    - source: {{pillar['sindexd_conf_tmpl']|default('salt://scality/sindexd/sindexd.conf.tmpl')}}
    - require:
      - file: scality-ringsh

