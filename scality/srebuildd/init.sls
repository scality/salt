
# do not include this state directly, use either scality.srebuildd.lighttpd or scality.srebuildd.apache instead

include:
  - scality.req
  - scality.repo
  - scality.python

srebuildd:
  pkg:
    - installed
{%- if pillar['scality'] is defined and pillar['scality']['version'] is defined %}
    - version: {{ salt['pillar.get']('scality:version') }}
{%- endif %}
    - name: scality-srebuildd
    - require:
      - pkgrepo: scality-repository
  service:
    - running
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

