
# do not include this state directly, use either scality.srebuildd.lighttpd or scality.srebuildd.apache instead

include:
  - scality.req
  - scality.repo
  - scality.python
  - .log

scality-srebuildd:
  pkg:
{%- if pillar['scality'] is defined and pillar['scality']['version'] is defined %}
    - version: {{ salt['pillar.get']('scality:version') }}
    - installed
{%- else %}
    - latest
{%- endif %}
    - require:
      - pkgrepo: scality-repository
  service:
    - running
    - enable: True
    - watch:
      - file: scality-srebuildd
  file:
    - managed
    - name: /etc/srebuildd.conf
    - template: jinja
    - source: salt://scality/srebuildd/srebuildd.conf.tmpl
    - require:
      - pkg: python-scalitycs
      - pkg: scality-srebuildd

